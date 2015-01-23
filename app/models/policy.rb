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
  # Include the fiscal year mixin
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

  # Has a single method for calculating costs
  belongs_to  :cost_calculation_type

  # Has a single method for calculating service life
  belongs_to  :service_life_calculation_type

  # Has a single method for estimating condition
  belongs_to  :condition_estimation_type

  # Has 0 or more policy items. The policy items are destroyed when the policy is destroyed
  has_many    :policy_items, :dependent => :destroy

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :organization,                      :presence => true
  validates :service_life_calculation_type,     :presence => true
  validates :cost_calculation_type,             :presence => true
  validates :condition_estimation_type,         :presence => true

  validates :year,                              :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => Date.today.year - 1 }
  validates :name,                              :presence => true
  validates :description,                       :presence => true
  validates :interest_rate,                     :presence => true, :numericality => {:greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0 }
  validates :condition_threshold,               :presence => true, :numericality => {:greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 5.0 }

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------

  # default scope
  default_scope { where(:active => true) }

  # set named scopes
  scope :current, -> { where(:current => true) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :organization_id,
    :service_life_calculation_type_id,
    :cost_calculation_type_id,
    :condition_estimation_type_id,
    :year,
    :name,
    :description,
    :interest_rate,
    :condition_threshold,
    :current,
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
  # Override numeric setters to remove any extraneous formats from the number strings eg $, etc.
  def year=(num)
    self[:year] = sanitize_to_int(num)
  end
  def interest_rate=(num)
    self[:interest_rate] = sanitize_to_float(num)
  end
  def condition_threshold=(num)
    self[:condition_threshold] = sanitize_to_float(num)
  end

  def to_s
    name
  end
  
  # Get the matching policy rule for this asset. If the rule is not found the query goes up the chain
  # so the parent policy is checked. This allows organiåtions to derive a policy and override only those
  # rules which are different from the parent rule
  def get_rule(asset)
    matcher = PolicyRuleService.new
    rule = matcher.match(self, asset)
    # Return this rule
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
    self.year ||= Date.today.year
    self.interest_rate ||= 0.01
    self.condition_threshold ||= 2.5
    self.active ||= true
  end

end
