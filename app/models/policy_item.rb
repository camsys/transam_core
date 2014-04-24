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
  validates :policy_id,               :presence => true
  validates :asset_subtype_id,        :presence => true
  validates :max_service_life_years,  :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :max_service_life_miles,                      :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}, :allow_nil => :true
  validates :replacement_cost,        :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :pcnt_residual_value,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
    
  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  default_scope { where(:active => true).order('asset_subtype_id ASC') }
  
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
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Override setters to remove any extraneous formats from the number strings eg $, etc.      
  def max_service_life_years=(num)
    self[:max_service_life_years] = sanitize_number(num)
  end      
  def max_service_life_miles=(num)
    self[:max_service_life_miles] = sanitize_number(num)
  end      
  def replacement_cost=(num)
    self[:replacement_cost] = sanitize_number(num)
  end      
  def pcnt_residual_value=(num)
    self[:pcnt_residual_value] = sanitize_number(num)
  end      
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Strip extraneous non-numeric characters from an input number and return a float
  def sanitize_number(num)
    num.to_s.scan(/\b-?[\d.]+/).join.to_f
  end

  # Set resonable defaults for a new policy
  def set_defaults
    self.max_service_life_years ||= 0
    self.max_service_life_miles ||= 0 
    self.replacement_cost ||= 0 
    self.active ||= true
  end    
      
  
end
