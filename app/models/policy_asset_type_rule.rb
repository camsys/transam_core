#-------------------------------------------------------------------------------
#
# PolicyAssetTypeRule
#
# Policy rule for an asset type for an organiation
#
#-------------------------------------------------------------------------------
class PolicyAssetTypeRule < ActiveRecord::Base

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

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
  belongs_to  :asset_type
  # Every asset type rule has a service life calculator
  belongs_to  :service_life_calculation_type
  # Every asset type rule has a replacement cost calculator
  belongs_to  :replacement_cost_calculation_type, :class_name => "CostCalculationType"
  # Every asset type rule has a condition rollup calculator
  belongs_to  :condition_rollup_calculation_type

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :policy,                        :presence => true
  validates :asset_type,                    :presence => true
  validates :service_life_calculation_type, :presence => true
  validates :replacement_cost_calculation_type, :presence => true
  validates :annual_inflation_rate,         :presence => true,  :numericality => {:greater_than_or_equal_to => 0.01, :less_than_or_equal_to => 100}
  validates :pcnt_residual_value,           :presence => true,  :numericality => {:only_integer => true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}

  #-----------------------------------------------------------------------------
  # Scopes
  #-----------------------------------------------------------------------------
  default_scope { order(:asset_type_id) }

  #-----------------------------------------------------------------------------
  # List of hash parameters allowed by the controller
  #-----------------------------------------------------------------------------
  FORM_PARAMS = [
    :id,
    :policy_id,
    :asset_type_id,
    :service_life_calculation_type_id,
    :replacement_cost_calculation_type_id,
    :condition_rollup_calculation_type_id,
    :annual_inflation_rate,
    :pcnt_residual_value,
    :condition_rollup_weight
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
    "#{asset_type}"
  end

  def name
    "Policy Rule #{asset_type}"
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.
  def annual_inflation_rate=(num)
    self[:annual_inflation_rate] = sanitize_to_float(num)
  end
  def pcnt_residual_value=(num)
    self[:pcnt_residual_value] = sanitize_to_int(num)
  end
  #------------------------------------------------------------------------------
  # Protected Methods
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.annual_inflation_rate ||= 1.1
    self.pcnt_residual_value ||= 0
    self.condition_rollup_weight ||= 0
  end

end
