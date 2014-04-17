#------------------------------------------------------------------------------
#
# GeolocatableAsset 
#
# Abstract class that adds location reference attributes to the base Asset class. All
# assets that can be geo-located should be drived from this base class
#
#------------------------------------------------------------------------------
class GeolocatableAsset < Asset

  DEFAULT_SEARCH_RADIUS     = SystemConfig.instance.search_radius
  DEFAULT_SEARCH_UNITS      = Unit.new(SystemConfig.instance.search_units)

  # ----------------------------------------------------  
  # Callbacks
  # ----------------------------------------------------  
  after_initialize :set_defaults

  # ----------------------------------------------------  
  # Geo Characteristics
  # ----------------------------------------------------  
  # Type of location reference used to geocode the asset
  belongs_to :location_reference_type
  #attr_accessible :location_reference_type_id
  
  # Actual location reference stored in native format
  #attr_accessible :location_reference
  # spatial field
  #attr_accessible :geometry
  
  # Comments regarding the location of the asset
  #attr_accessible :location_comments

  # ----------------------------------------------------  
  # Validations
  # ----------------------------------------------------  
  # Validations for location
  validates :location_reference_type_id, :presence => true
  validates :location_reference, :presence => true
        
  # custom validator for location_reference
  validate  :validate_location_reference
  
  #------------------------------------------------------------------------------
  # Lists. These lists are used by derived classes to make up lists of attributes
  # that can be used for operations like full text search etc. Each derived class
  # can add their own fields to the list
  #------------------------------------------------------------------------------
  
  SEARCHABLE_FIELDS = [
  ] 
  CLEANSABLE_FIELDS = [
  ] 
  
  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :location_reference_type_id,
    :location_reference,
    :geometry
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
    
  # returns true if this instance has a geometry that can be mapped, false
  # otherwise
  def mappable?
    ! geometry.nil?
  end
  
  # returns true if this instance can be geo_located. Always true
  def geo_locatable?
    true
  end
  
  # Returns a spatial search around an asset. The search is contrained by a minimim size bounding box that would contain
  # a circle of radius search_radius feet around the asset. Uses a native quesry and spatial index to optimize the search
  # the default is to search within one 300 ft (100 yds)
  def find_close(search_radius = DEFAULT_SEARCH_RADIUS, units = DEFAULT_SEARCH_UNITS)
    
    gis_service = GisService.new
    search_box = gis_service.search_box_from_point(geometry, search_radius, units)
    query_str = "SELECT * FROM assets WHERE MBRContains(GeomFromText('#{search_box.as_wkt}'), geometry) = 1"      
    Rails.logger.debug(query_str)
    Asset.find_by_sql(query_str) 
    
  end
  
  def searchable_fields
    a = super
    SEARCHABLE_FIELDS.each do |field|
      a << field
    end
    a
  end
  
  def cleansable_fields
    a = super
    CLEANSABLE_FIELDS.each do |field|
      a << field
    end
    a
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new generic sign
  def set_defaults
    super
  end    

  # validation to ensure that a coordinate can be derived from the location reference
  def validate_location_reference
    if location_reference_type_id.nil?
      return false
    end
    
    parser = LocationReferenceService.new
    type = LocationReferenceType.find(location_reference_type_id)
    parser.parse(location_reference, type.format)
    if parser.errors.empty?
      self.geometry = parser.geometry
      self.location_reference = parser.formatted_location_reference
      return true
    else
      errors.add(:location_reference, parser.errors)
      return false      
    end
  end

end