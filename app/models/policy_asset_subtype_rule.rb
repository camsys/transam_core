#-------------------------------------------------------------------------------
#
# PolicyAssetSubtypeRule
#
# Policy rule for an asset type for an organiation
#
#-------------------------------------------------------------------------------
class PolicyAssetSubtypeRule < ActiveRecord::Base

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers
  include FiscalYear

  #-----------------------------------------------------------------------------
  # Callbacks
  #-----------------------------------------------------------------------------
  after_initialize :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every policy rule belongs to a policy, and thus an organization
  belongs_to  :policy
  # Every one of these rules applies to an asset type
  belongs_to  :asset_subtype
  # Every one of these rules applies to an asset type
  belongs_to  :replace_asset_subtype, :class_name => 'AssetSubtype', :foreign_key => :replace_asset_subtype_id

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :policy,                  :presence => true
  validates :asset_subtype,           :presence => true

  validates :min_service_life_months,  :presence => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :replacement_cost,         :presence => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :cost_fy_year,             :presence => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates_inclusion_of :replace_with_new, :in => [true, false]
  validates_inclusion_of :replace_with_leased, :in => [true, false]
  validates :lease_length_months,       :allow_nil => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}

  validates :rehabilitation_service_month,     :presence => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :rehabilitation_labor_cost,     :allow_nil => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :rehabilitation_parts_cost,     :allow_nil => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}
  validates :extended_service_life_months, :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0}

  validates :min_used_purchase_service_life_months, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  # Custom validator for checking values against parent policies
  validate :validate_min_allowable_policy_values

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { order(:asset_subtype_id) }

  #-----------------------------------------------------------------------------
  # List of hash parameters allowed by the controller
  #-----------------------------------------------------------------------------
  FORM_PARAMS = [
    :id,
    :policy_id,
    :asset_subtype_id,
    :min_service_life_months,
    :replacement_cost,
    :cost_fy_year,
    :replace_with_new,
    :replace_with_leased,
    :replace_asset_subtype_id,
    :replacement_cost,
    :lease_length_months,

    :rehabilitation_service_month,
    :rehabilitation_labor_cost,
    :rehabilitation_parts_cost,
    :extended_service_life_months,

    :min_used_purchase_service_life_months
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------
  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  # Returns the total rehabilitation cost for the asset type
  def total_rehabilitation_cost
    rehabilitation_labor_cost.to_i + rehabilitation_parts_cost.to_i
  end

  def to_s
    "#{asset_subtype.asset_type}: #{asset_subtype}"
  end

  def name
    "Policy Rule #{asset_subtype}"
  end


  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def min_service_life_months=(num)
    self[:min_service_life_months] = sanitize_to_int(num)
  end
  def replacement_cost=(num)
    self[:replacement_cost] = sanitize_to_int(num)
  end
  def lease_length_months=(num)
    self[:lease_length_months] = sanitize_to_int(num)
  end
  def rehabilitation_service_month=(num)
    self[:rehabilitation_service_month] = sanitize_to_int(num)
  end
  def rehabilitation_labor_cost=(num)
    self[:rehabilitation_labor_cost] = sanitize_to_int(num)
  end
  def rehabilitation_parts_cost=(num)
    self[:rehabilitation_parts_cost] = sanitize_to_int(num)
  end
  def extended_service_life_months=(num)
    self[:extended_service_life_months] = sanitize_to_int(num)
  end
  def min_used_purchase_service_life_months=(num)
    self[:min_used_purchase_service_life_months] = sanitize_to_int(num)
  end

  #-----------------------------------------------------------------------------
  def minimum_value(attr, default = 0)
    # This method determines the minimum value allowed for an input for a particular attribute.
    # It allows us to set the appropriate minimum value for the inputs on the form.

    if policy.parent.present?
      parent_rule = policy.parent.policy_asset_subtype_rules.find_by(asset_subtype: self.asset_subtype)
      if parent_rule.present?
        parent_rule.send attr.to_s
      else
        default
      end
    else
      default
    end
  end

  def min_allowable_policy_values(subtype=nil)
    subtype = self.asset_subtype if subtype.nil?
    # This method gets the min values for child orgs that are not less than the value
    # set by the parent org
    results = Hash.new

    if policy.present? and policy.parent.present?
      attributes_to_compare = [
        :min_service_life_months,
        :extended_service_life_months,
        :min_used_purchase_service_life_months
      ]

      parent_rule = policy.parent.policy_asset_subtype_rules.find_by(asset_subtype: subtype)

      if parent_rule.present?
        attributes_to_compare.each do |attr|
          results[attr] = parent_rule.send(attr)
        end
      end
    end
    results
  end
  #-----------------------------------------------------------------------------
  # Protected Methods
  #-----------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.min_service_life_months ||= 0
    self.replacement_cost ||= 0
    self.lease_length_months ||= 0
    self.rehabilitation_service_month ||= 0
    self.rehabilitation_labor_cost ||= 0
    self.rehabilitation_parts_cost ||= 0
    self.extended_service_life_months ||= 0
    self.min_used_purchase_service_life_months ||= 0
    self.cost_fy_year ||= current_planning_year_year
  end

  #-----------------------------------------------------------------------------
  private
  #-----------------------------------------------------------------------------

  def validate_min_allowable_policy_values
    # This method validates that values for child orgs are not less than the value
    # set by the parent org
    return_value = true

    min_allowable_policy_values.each do |attr, val|
      # Make sure we don't try to test nil values. Other validations should
      # take care of these
      if self.send(attr).blank?
        next
      end

      if self.send(attr) < val
        errors.add(attr, "cannot be less than #{val}, which is the minimum set by #{ policy.parent.organization.short_name}'s policy")
        return_value = false
      end
    end

    return_value
  end

end
