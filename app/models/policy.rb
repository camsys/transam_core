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

  # Returns true of the policy has a rule for the asset type. false otherwise
  def asset_type_rule? asset_type
    asset_type_rule(asset_type).present?
  end
  # Returns the policy type rule for the asset typoe. Nil if it does not exist
  def asset_type_rule asset_type
    policy_asset_type_rules.find_by(:asset_type_id => asset_type.id)
  end

  # Returns true of the policy has a rule for the asset subtype. false otherwise`
  def asset_subtype_rule? asset_subtype
    asset_subtype_rule(asset_subtype).present?
  end
  # Returns the policy subtype rule for the asset subtype. Nil if it does not exist
  def asset_subtype_rule asset_subtype, fuel_type=nil
    fuel_type.nil? ?
      policy_asset_subtype_rules.find_by(:asset_subtype_id => asset_subtype.id) :
      policy_asset_subtype_rules.find_by(:asset_subtype_id => asset_subtype.id, :fuel_type => fuel_type.id)

  end

  # Returns the policy asset type rule for a given asset. If the asset type rule
  # does not exit in this policy it is created from the parent policy and added
  # to this policy first and then returned
  #
  # Raises a runtime error if the policy is a top level policy (no parent) or the
  # parent does not contain the rule
  def find_or_create_asset_type_rule asset_type

    rule = asset_type_rule asset_type
    if rule.blank?
      # Check the parent
      if parent.present?
        parent_rule = parent.policy_asset_type_rules.find_by(:asset_type_id => asset_type.id)
        # Chrck to see of we got a rule
        if parent_rule.present?
          rule = parent_rule.dup
          rule.policy = self
          rule.save
        else
          raise  "Rule for asset type #{asset_type} was not found in the parent policy."
        end
      else
        raise "Policy is a top level policy"
      end
    end
    rule
  end

  # Returns the policy asset type rule for a given asset. If the asset type rule
  # does not exit in this policy it is created from the parent policy and added
  # to this policy first and then returned
  #
  # Raises a runtime error if the policy is a top level policy (no parent) or the
  # parent does not contain the rule
  def find_or_create_asset_subtype_rule asset_subtype, fuel_type=nil

    rule = asset_subtype_rule asset_subtype, fuel_type
    if rule.blank?
      # Check the parent
      if parent.present?

        if fuel_type.present?
          parent_rule = parent.policy_asset_subtype_rules.find_by(:asset_subtype_id => asset_subtype.id, :fuel_type => fuel_type.id)
        end

        if parent_rule.nil?
          parent_rule = parent.policy_asset_subtype_rules.find_by(:asset_subtype_id => asset_subtype.id)
        end

        # Check to see of we got a rule
        if parent_rule.present?
          rule = parent_rule.dup
          rule.policy = self

          #If we picked up the default subtype rule then make sure we set the fuel rule here so there is on for this asset now and in the future.
          if fuel_type.present? && rule.fuel_type_id != fuel_type.id
            rule.fuel_type_id = fuel_type.id
          end

          rule.save


        else
          raise "Rule for asset subtype #{asset_subtype} was not found in the parent policy."
        end
      else
        raise "Policy is a top level policy."
      end
    end
    rule
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
