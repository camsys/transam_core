#------------------------------------------------------------------------------
# AssetGroup
#
# HBTM relationship with assets. Used as a generic bucket for grouping assets
# into loosely defined collections
#
#------------------------------------------------------------------------------
class AssetGroup < ActiveRecord::Base
        
  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /asset_event/{object_key}/...
  def to_param
    object_key
  end
      
  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
          
  # Associations
  
  # Every asset group is owned by an organization
  belongs_to :organization
    
  # Every asset grouop has zero or more assets
  has_and_belongs_to_many :assets

  # default scope
  default_scope { where(:active => true) }
  
  validates :object_key,            :presence => true, :uniqueness => true
  validates :organization,          :presence => true
  validates :name,                  :presence => true
  validates :code,                  :presence => true
  validates :description,           :presence => true
  
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :name, 
    :code, 
    :description, 
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
    name
  end   
  
end
