class Location < ActiveRecord::Base
            
  # Include the unique key mixin
  include UniqueKey
  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the key as the restful parameter. All URLS will be of the form
  # /location/{object_key}/...
  def to_param
    object_key
  end

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
            
  # Associations
  belongs_to  :location_type
  belongs_to  :organization
  has_many    :assets
  
  # Enable automatic geocoding using the Geocoder gem
  geocoded_by       :full_address
  after_validation  :geocode  
      
  validates :object_key,            :presence => true, :uniqueness => true
  validates :name,                  :presence => true
  validates :location_type_id,      :presence => true
  validates :address1,              :presence => true
  validates :city,                  :presence => true
  validates :state,                 :presence => true
  validates :zip,                   :presence => true
    
  # default scope
  default_scope { where(:active => true) }

  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :object_key,
    :location_type_id,
    :organization_id,
    :name,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :active,
    :latitude,
    :longitude
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
                                  
  def full_address
    elems = []
    elems << address1 unless address1.blank?
    elems << address2 unless address2.blank?
    elems << city unless city.blank?
    elems << state unless state.blank?
    elems << zip unless zip.blank?
    elems.compact.join(', ')    
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new organization
  def set_defaults
    self.active ||= true
  end    
  
end
      
