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

  #------------------------------------------------------------------------------
  # Validations common to all vendors
  #------------------------------------------------------------------------------
  validates :name,           :presence => true  

  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :name,
    :organization_type_id,
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
      
  # returns a typed value of the organization if one exists
  def self.get_typed_organization(org)
    if org
      class_name = org.organization_type.class_name
      klass = Object.const_get class_name
      o = klass.find(org.id)
      return o
    end
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
      
