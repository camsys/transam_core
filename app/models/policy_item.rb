#------------------------------------------------------------------------------
#
# PolicyItem
#
#------------------------------------------------------------------------------
class PolicyItem < ActiveRecord::Base
  
  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  belongs_to  :policy
  belongs_to  :asset_subtype
  belongs_to  :replace_asset_subtype, :class_name => 'AssetSubtype', :foreign_key => :replace_asset_subtype_id

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates :policy,                  :presence => true
  validates :asset_subtype,           :presence => true
  validates :max_service_life_months,  :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :replacement_cost,        :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :pcnt_residual_value,     :presence => true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates :rehabilitation_cost,     :allow_nil => :true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :extended_service_life_months,     :allow_nil => :true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}
  validates :rehabilitation_year,     :allow_nil => :true,  :numericality => {:only_integer => :true,   :greater_than_or_equal_to => 0}, :allow_nil => :true
    
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
    :max_service_life_months, 
    :replacement_cost, 
    :rehabilitation_cost,
    :extended_service_life_months,
    :pcnt_residual_value,
    :replacement_ali_code,
    :rehabilitation_ali_code,
    :rehabilitation_year,
    :replace_asset_subtype_id,
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

  def to_s
    "#{asset_subtype}"
  end

  # Override setters to remove any extraneous formats from the number strings eg $, etc.      
  def max_service_life_months=(num)
    self[:max_service_life_months] = sanitize_to_int(num)
  end      
  def replacement_cost=(num)
    self[:replacement_cost] = sanitize_to_int(num)
  end      
  def rehabilitation_cost=(num)
    self[:rehabilitation_cost] = sanitize_to_int(num)
  end      
  def extended_service_life_months=(num)
    self[:extended_service_life_months] = sanitize_to_int(num)
  end      
  def pcnt_residual_value=(num)
    self[:pcnt_residual_value] = sanitize_to_int(num)
  end      

  def max_service_life_years
    max_service_life_months / 12.0
  end
  def max_service_life_years=(num)
    self[:max_service_life_months] = sanitize_to_int(num) / 12.0
  end      
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new policy
  def set_defaults
    self.max_service_life_months ||= 0
    self.replacement_cost ||= 0 
    self.extended_service_life_months ||= 0
    self.rehabilitation_cost ||= 0 
    self.rehabilitation_year ||= 0
    self.active ||= true
  end    
        
end
