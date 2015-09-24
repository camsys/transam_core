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

  def require_type_rules_for_asset_type?(asset_type)
    # We should only create rules when the organization first acquires an asset type
    !PolicyAssetTypeRule.exists?(policy: self, asset_type: asset_type)
  end

  def require_subtype_rules_for_asset_subtype?(asset_subtype)
    # We should only create rules when the organization first acquires an asset subtype
    !PolicyAssetSubtypeRule.exists?(policy: self, asset_subtype: asset_subtype)
  end

  def load_type_rules_from_parent(asset_type)
    # When initially creating rules for a new asset type, look to the parent policy to create the default rules for that subtype
    # This method uses a rescue block to handle cases where the parent policy does not have an appropriate rule
    begin
      parent_rule = parent.policy_asset_type_rules.find_by(asset_type: asset_type)
      new_rule = parent_rule.dup
      new_rule.policy = self
      new_rule.save
    rescue Exception => e
      Rails.logger.warn e.message
    end
  end

  def load_subtype_rules_from_parent(asset_subtype)
    # When initially creating rules for a new subtype, look to the parent policy to create the default rules for that subtype
    # This method uses a rescue block to handle cases where the parent policy does not have an appropriate rule
    begin
      parent_rule = parent.policy_asset_subtype_rules.find_by(asset_subtype: asset_subtype)
      new_rule = parent_rule.dup
      new_rule.policy = self
      new_rule.save
    rescue Exception => e
      Rails.logger.warn e.message
    end
  end

  def check_for_type_rule(asset_type)
    raise Exception.new("This policy does not have a asset type rule for #{asset_type}") if !PolicyAssetTypeRule.exists?(policy: self, asset_type: asset_type)
  end

  def check_for_subtype_rule(asset_subtype)
    raise Exception.new("This policy does not have a asset type rule for #{asset_subtype}") if !PolicyAssetTypeRule.exists?(policy: self, asset_subtype: asset_subtype)
  end

  def check_for_asset_rules(asset)
    begin
      check_for_type_rule(asset.asset_type)
      check_for_subtype_rule(asset.asset_subtype)
    rescue Exception
      Rails.logger.warn Exception
    end
  end

  def ensure_rules_for_asset(asset)
    if parent.present?
      load_type_rules_from_parent(asset.asset_type) if require_type_rules_for_asset_type?(asset.asset_type)
      load_subtype_rules_from_parent(asset.asset_subtype) if require_subtype_rules_for_asset_subtype?(asset.asset_subtype)
    else
      check_for_asset_rules(asset)
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
