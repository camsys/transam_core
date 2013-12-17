#------------------------------------------------------------------------------
#
# Organization
#
# Represents a basic organization in a flat organizational hierarchy
# without any relationships to other organizations
#
#------------------------------------------------------------------------------
class Organization < ActiveRecord::Base
  
  # Enable auditing of this model type
  has_paper_trail

  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Enable automatic geocoding using the Geocoder gem
  geocoded_by :full_address
  after_validation :geocode  

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  #require rails to use the org short name as the restful parameter. All URLS will be of the form
  # /org/{short_name}/...
  def to_param
    short_name
  end

  #------------------------------------------------------------------------------
  # Associations common to all organizations
  #------------------------------------------------------------------------------
  # Every organization belongs to a customer
  belongs_to :customer
  # Every organization has a type
  belongs_to :organization_type
  
  # Every organization can own a set of assets
  has_many :assets
  # Every organization can have a set of users
  has_many :users
  
  # Every organization can have a set of policies
  has_many :policies
  
  # Every organization can have messages
  has_many :messages
  
  #has_many :user_organization_maps
    
  # Accessors for associations
  #attr_accessible :customer_id, :organization_type_id
  
  validates :customer_id,           :presence => true
  validates :organization_type_id,  :presence => true
  
  #------------------------------------------------------------------------------
  # Attributes common to all organization types
  #------------------------------------------------------------------------------
  # true if this organization holds the license for TransAM
  #attr_accessible :license_holder
  # names for the org. The short name must be unique
  #attr_accessible :name, :short_name
  # address and contact info
  #attr_accessible :address1, :address2, :city, :state, :zip, 
  #                :phone, :fax, :url 
  # other derived attributes                
  #attr_accessible :active
  
  # geocoded location for the organization
  #attr_accessible :latitude, :longitude  

  validates :name,                  :presence => true
  validates :address1,              :presence => true
  validates :city,                  :presence => true
  validates :state,                 :presence => true
  validates :zip,                   :presence => true
  #validates :license_holder, :presence => true
  validates :phone,                 :presence => true


  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
      
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
      
  # This base class is not aware of any workorders  
  def workorder_aware?
    false
  end
  
  # returns the count of assets of the given type
  def asset_count(asset_type) 
    return assets.where('asset_type_id = ?', asset_type.id).count
  end
  
  # Returns a policy for an untyped organization
  def get_policy
    # get a typed version of the organization and return the
    # results of the typed org
    org = Organization.get_typed_organization(self)
    return org.get_policy unless org.nil?
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
  
  def html_address
    html = address1
    html << "<br/>"
    html << address2 unless address2.blank?
    html << "<br/>" unless address2.blank?
    html << city
    html << ", "
    html << state
    html << ", "
    html << zip
    html << "<br/>"
    
    return html.html_safe
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
      
