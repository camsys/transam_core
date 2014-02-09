class Location < ActiveRecord::Base
            
  # Associations
  belongs_to  :location_type
  belongs_to  :organization
  has_many    :assets
  
  # Enable automatic geocoding using the Geocoder gem
  geocoded_by       :full_address
  after_validation  :geocode  
      
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
      
