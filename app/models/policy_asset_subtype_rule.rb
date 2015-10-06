#------------------------------------------------------------------------------
#
# PolicyAssetSubtypeRule
#
# Policy rule for an asset type for an organiation
#
#------------------------------------------------------------------------------
class PolicyAssetSubtypeRule < ActiveRecord::Base

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers
  include FiscalYear

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #-----------------------------------------------------------------------------
  # Associations
  #-----------------------------------------------------------------------------
  # Every policy rule belongs to a policy, and thus an organization
  belongs_to  :policy
  # Every one of these rules applies to an asset type
  belongs_to  :asset_subtype

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :policy,                  :presence => true
  validates :asset_subtype,           :presence => true

  validates :min_service_life_months,  :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :replacement_cost,         :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :cost_fy_year,             :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates_inclusion_of :replace_with_new, :in => [true, false]
  validates_inclusion_of :replace_with_leased, :in => [true, false]
  validates :replacement_cost,          :allow_nil => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :lease_length_months,       :allow_nil => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}

  validates :rehabilitation_service_month,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :rehabilitation_cost,      :allow_nil => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :extended_service_life_months, :allow_nil => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}

  validates :min_used_purchase_service_life_months, :presence => true, :numericality => {:only_integer => :true, :greater_than_or_equal_to => 0}
  validate :greater_or_equal_to_parent_value

  #------------------------------------------------------------------------------
  # List of hash parameters allowed by the controller
  #------------------------------------------------------------------------------
  FORM_PARAMS = [
    :id,
    :policy_id,
    :asset_subtype_id,
    :min_service_life_months,
    :replacement_cost,
    :cost_fy_year,
    :replace_with_new,
    :replace_with_leased,
    :replacement_cost,
    :lease_length_months,

    :rehabilitation_service_month,
    :rehabilitation_cost,
    :extended_service_life_months,

    :min_used_purchase_service_life_months
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
  def rehabilitation_cost=(num)
    self[:rehabilitation_cost] = sanitize_to_int(num)
  end
  def extended_service_life_months=(num)
    self[:extended_service_life_months] = sanitize_to_int(num)
  end
  def min_used_purchase_service_life_months=(num)
    self[:min_used_purchase_service_life_months] = sanitize_to_int(num)
  end

  def minimum_value(attr, default = 0)
    # This method determines the minimum value allowed for an input for a particular attribute.
    # It allows us to set the appropriate minimum value for the inputs on the form.

    if policy.parent.present?
      parent_rule = policy.parent.policy_asset_subtype_rules.find_by(asset_subtype: self.asset_subtype)
      parent_rule.send attr.to_s
    else
      default
    end
  end


  private

  def greater_or_equal_to_parent_value
    # This method validates that values for child orgs are not less than the value set by the parent org
    if policy.parent.present?
      attributes_to_compare = [
        :min_service_life_months,
        :min_used_purchase_service_life_months
      ]

      parent_rule = policy.parent.policy_asset_subtype_rules.find_by(asset_subtype: self.asset_subtype)

      attributes_to_compare.each do |attribute|
        parent_value = parent_rule.send(attribute)
        if self.send(attribute) < parent_value
          errors.add(attribute, " cannot be less than #{parent_value}, which is the minimum set by #{ policy.parent.organization.short_name}'s policy")
        end
      end
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
    self.min_service_life_months ||= 0
    self.replacement_cost ||= 0
    self.lease_length_months ||= 0
    self.rehabilitation_service_month ||= 0
    self.rehabilitation_cost ||= 0
    self.extended_service_life_months ||= 0
    self.min_used_purchase_service_life_months ||= 0
    self.cost_fy_year ||= current_planning_year_year
  end

end
