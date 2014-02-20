#------------------------------------------------------------------------------
#
# PolicyItem
#
#------------------------------------------------------------------------------
class PolicyItem < ActiveRecord::Base
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :policy
  belongs_to  :asset_subtype

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :policy_id, :presence => true
  validates :asset_subtype_id, :presence => true
  validates :max_service_life_years, :presence => true  
  validates :max_service_life_miles, :presence => true
  validates_numericality_of :replacement_cost,    :only_integer => :true,   :greater_than_or_equal_to => 0
  validates_numericality_of :pcnt_residual_value, :only_integer => :true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope where(:active => true)
  
  #------------------------------------------------------------------------------
  # List of hash parameters allowed by the controller
  #------------------------------------------------------------------------------
  FORM_PARAMS = [
    :policy_id,
    :asset_subtype_id, 
    :max_service_life_years, 
    :max_service_life_miles, 
    :replacement_cost, 
    :pcnt_residual_value,
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
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.max_life_years ||= 0
    self.max_life_miles ||= 0 
    self.replacement_cost ||= 0 
    self.active ||= true
  end    
      
  
end
