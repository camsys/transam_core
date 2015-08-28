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

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults

  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every policy belongs to an organization
  belongs_to  :organization

  belongs_to :service_life_calculation_type

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
