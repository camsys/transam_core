#------------------------------------------------------------------------------
#
# Policy
#
#------------------------------------------------------------------------------
class Policy < ActiveRecord::Base
  
  # Enable auditing of this model type
  has_paper_trail
  
  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /policy/{object_key}/...
  def to_param
    object_key
  end
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize :set_defaults
  
  # Always generate a unique object key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
  
  #------------------------------------------------------------------------------
  # Associations
  #------------------------------------------------------------------------------
  # Every policy belongs to an organization
  belongs_to  :organization

  # Has a single method for calculating costs
  belongs_to  :cost_calculation_type
  
  # Has a single method for calculating service life
  belongs_to  :service_life_calculation_type
  
  # Has a single method for estimating condition
  belongs_to  :condition_estimation_type

  #------------------------------------------------------------------------------
  # Attributes common to policies
  #------------------------------------------------------------------------------
      
  # Every policy has an effective year
  #attr_accessible :year
  # Every policy has a name and a description it is identified by
  #attr_accessible :name
  #attr_accessible :description
   
  # Interest rate used to determine future cost calculations. In the range (0..1)
  #attr_accessible :interest_rate

  # Condition threshold used to determine if an asset is in need or replacement
  #attr_accessible :condition_threshold
  
  #attr_accessible :active

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------
  validates  :object_key,                       :presence => true, :uniqueness => true
  validates :organization_id,                   :presence => true
  validates :service_life_calculation_type_id,  :presence => true
  validates :cost_calculation_type_id,          :presence => true
  validates :condition_estimation_type_id,      :presence => true

  validates :year,                              :presence => true
  validates :name,                              :presence => true
  validates :description,                       :presence => true
  validates :interest_rate,                     :presence => true
  validates :condition_threshold,               :presence => true

  #------------------------------------------------------------------------------
  # Scopes
  #------------------------------------------------------------------------------
  
  # default scope
  default_scope { where(:active => true) }

  # set named scopes 
  scope :current, -> { where(:current => true) }

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
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
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected 

  # Set resonable defaults for a new policy
  def set_defaults
    self.year ||= Date.today.year
    self.interest_rate ||= 0.02
    self.condition_threshold ||= 2.5 
    self.active ||= true
  end    
      
end
