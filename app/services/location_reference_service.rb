#
# Centralizes all the logic for encoding, checking and parsing location references
#
class LocationReferenceService

  COORDINATE      = "COORDINATE"
  LRS             = "LRS"
  ADDRESS         = "ADDRESS"
  WELL_KNOWN_TEXT = "WELL_KNOWN_TEXT"   
  
  COORD_REGEX = /^(\()([-+]?)([\d]{1,2})(((\.)(\d+)(,)))(\s*)(([-+]?)([\d]{1,3})((\.)(\d+))?(\)))$/
  FLOAT_REGEX = /([+-]?\d+\.?\d+)\s*,\s*([+-]?\d+\.?\d+)/
    
  attr_accessor :location_reference
  attr_accessor :format
  attr_accessor :geometry, :formatted_location_reference
  attr_accessor :errors
  attr_reader   :gis_service
  
  def initialize(attrs = {})
    # reset the current state
    reset
    @gis_service = GisService.new
    
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
  
  def has_errors
    return @errors.count > 0
  end 
  
  # Parses a location reference and returns a geometry object or nil if the parse
  # fails.
  def parse(locref, format)
    Rails.logger.debug "parse '#{locref}', format = '#{format}'"
    # reset the current state
    reset
    @location_reference = locref
    @format = format
    
    if format == COORDINATE
      parse_coordinate(locref)
    elsif format == LRS
      geocode_lrs(locref)
    elsif format == ADDRESS
      geocode_address(locref)
    elsif format == WELL_KNOWN_TEXT
      parse_wkt(locref)
    else
      message = "Unknown location reference format #{format}"
      @errors << message      
    end
    [@errors.empty?, @errors, @location]
  end

  def encode_coordinate(lng, lat)
    "(#{format_coord_part(lng)},#{format_coord_part(lat)})"
  end

  protected

  def parse_coordinate(locref)
    Rails.logger.debug "COORDINATE #{locref}"
    # ensure that the string is corrcetly defined
    m = COORD_REGEX.match(locref)
    if m
      # match floats in the string which are returned as an array
      matches = locref.scan(FLOAT_REGEX).flatten
      longitude = matches[0]
      latitude = matches[1]
      @formatted_location_reference = encode_coordinate(latitude, longitude)
      @geometry = @gis_service.as_point(longitude, latitude)
    else
      message = "Coordinate is incorrectly formatted. Use '(logitude,latitude)' format."
      @errors << message            
    end
  end

  def parse_wkt(locref)
    Rails.logger.debug "WELL_KNOWN_TEXT '#{locref}'"
    begin
      @geometry = @gis_service.from_wkt(locref)
      @formatted_location_reference = @geometry.as_wkt
    rescue
      message = "WKT is incorrectly formatted."
      @errors << message            
    end
  end
  
  def geocode_address(raw_address)
    Rails.logger.debug "ADDRESS #{raw_address}"

    geocoder = GeocodingService.new
    geocoder.geocode(raw_address)
    if geocoder.has_errors
      geocoder.errors.each do |e|
        @errors << e
      end
    else
      addr = geocoder.results.first
      latitude = addr[:lat]
      longitude = addr[:lon]
      @geometry = @gis_service.as_point(latitude, longitude)
      @formatted_location_reference = addr[:formatted_address]
    end
  end
  
  def geocode_lrs(locref)
    Rails.logger.debug "LRS #{locref}"
    message = "GIS LRS Service is not installed. Unable to locate reference."
    @errors << message                
  end


  def format_coord_part(val)
    sprintf('%0.8f', val)
  end
 
  def reset
    @geometry = nil
    @formatted_location_reference = nil
    @errors = []
  end
    
end