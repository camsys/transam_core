#------------------------------------------------------------------------------
#
# Vendor
#
# Represents a vendor that assets or services have been purchased from
#
#------------------------------------------------------------------------------
class Vendor < ActiveRecord::Base

  # Include the object key mixin
  include TransamObjectKey
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Enable automatic geocoding using the Geocoder gem
  geocoded_by       :full_address
  after_validation  :geocode  

  #------------------------------------------------------------------------------
  # Associations common to all vendors
  #------------------------------------------------------------------------------

  # Every vendor is owned by an organization
  belongs_to :organization

  # Every vendor has 0 or more assets
  has_many   :assets
  
  #------------------------------------------------------------------------------
  # Validations common to all vendors
  #------------------------------------------------------------------------------
  validates :name,           :presence => true  
  validates :organization,   :presence => true
  
  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :name,
    :organization_id,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :phone,
    :fax,
    :url,
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
          
  def to_s
    name
  end
  
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
      
