#------------------------------------------------------------------------------
#
# Policy
#
#------------------------------------------------------------------------------
class Policy < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey
  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers
  # Include the object key mixin
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every policy belongs to an organization
  belongs_to  :organization

  belongs_to :cost_calculation_type

  # Every policy can have a parent policy
  belongs_to  :parent, :class_name => 'Policy', :foreign_key => :parent_id

  # Has a single method for estimating condition
  belongs_to  :condition_estimation_type

  # Has 0 or more asset type rules. These are removed if the policy is removed
  has_many    :policy_asset_type_rules, :dependent => :destroy

  # Has 0 or more asset subtype rules. These are removed if the policy is removed
  has_many    :policy_asset_subtype_rules, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,                      :presence => true
  validates :description,                       :presence => true
  validates :condition_estimation_type,         :presence => true
  validates :condition_threshold,               :presence => true, :numericality => {:greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 5.0 }

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope

  # set named scopes
  scope :active, -> { where(:active => true) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :description,
    :condition_estimation_type_id,
    :condition_threshold,
    :active
  ]

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  def condition_threshold=(num)
    self[:condition_threshold] = sanitize_to_float(num)
  end

  def name
    "#{organization.short_name} Policy"
  end

  def to_s
    name
  end

  def missing_type_rules_for_asset_type?(asset_type)
    # This method checks to see if this policy has the right rule for this asset type
    !PolicyAssetTypeRule.exists?(policy: self, asset_type: asset_type)
  end

  def missing_subtype_rules_for_asset_subtype?(asset_subtype)
    # This method checks to see if this policy has the right rule for this asset subtype
    !PolicyAssetSubtypeRule.exists?(policy: self, asset_subtype: asset_subtype)
  end

  def load_type_rules_from_parent(asset_type)
    # When initially creating rules for a new asset type, look to the parent policy to create the default rules for that subtype
    # This method uses a rescue block to handle cases where the parent policy does not have an appropriate rule
    begin
      parent_rule = PolicyAssetTypeRule.find_by(policy: parent, asset_type: asset_type)
      new_rule = parent_rule.dup
      new_rule.policy = self
      new_rule.save
    rescue Exception => e
      Rails.logger.warn e.message
    end
  end

  def load_subtype_rules_from_parent(asset_subtype)
    # When initially creating rules for a new asset type, look to the parent policy to create the default rules for that subtype
    # This method uses a rescue block to handle cases where the parent policy does not have an appropriate rule
    begin
      parent_rule = PolicyAssetSubtypeRule.find_by(policy: parent, asset_subtype: asset_subtype)
      new_rule = parent_rule.dup
      new_rule.policy = self
      new_rule.save
    rescue Exception => e
      Rails.logger.warn e.message
    end
  end

  def check_self_for_asset_rules(asset)
    if missing_type_rules_for_asset_type?(asset.asset_type)
      raise StandardError.new("#{ self } is missing rules for #{ asset.asset_type.pluralize }.")
    elsif missing_subtype_rules_for_asset_subtype?(asset.asset_subtype)
      raise StandardError.new("#{ self } is missing rules for #{ asset.asset_subtype.pluralize }.")
    end
  end

  def ensure_rules_for_asset(asset)
    # This method checks to see if this policy is a parent policy.  If it is, it checks to see if it has the right rules for the asset.
    # If this policy is not a parent policy, then it checks to see if it has the right rules for the asset, and then loads missing rules from the parent.

    if parent.present?
      load_type_rules_from_parent(asset.asset_type) if missing_type_rules_for_asset_type?(asset.asset_type)
      load_subtype_rules_from_parent(asset.asset_subtype) if missing_subtype_rules_for_asset_subtype?(asset.asset_subtype)
    else
      check_self_for_asset_rules(asset)
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.condition_threshold ||= 2.5
  end

end
