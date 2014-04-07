class GisService
  
  DEFAULT_SRID        = SystemConfig.instance.srid
  
  DEG2RAD             = 0.0174532925199433    # Pi / 180 
  RAD2DEG             = 57.29577951308232     # 180 / Pi
  
  EARTHS_RADIUS_MILES = 3959      # earth's mean radius, miles
  EARTHS_RADIUS_KM    = 6371      # earth's mean radius, km

  DD_TO_MILES         = 65.5375   # Approximate number of miles in a decimal degree
  MILES_TO_METERS     = 1609.344  # Number of meters in a mile
  MILES_TO_KM         = 1.609344  # Number of kilometers in a mile
  
  # Distance metrics that can be used to define linear distances
  INCH                = Unit.new('in')
  FEET                = Unit.new('ft')
  YARD                = Unit.new('yd')
  MILE                = Unit.new('mi')
  METER               = Unit.new('m')
  KILOMETER           = Unit.new('km')
  
  # Allow an optional SRID to be configured. This will be added to all geometries created
  attr_reader         :srid
  # Input unit
  attr_reader         :input_unit
  # output_unit
  attr_reader         :output_unit
  
  
  def initialize(attrs = {})
    @srid = DEFAULT_SRID
    @input_unit = MILE
    @output_unit = MILE
    @geometry_factory = GeometryFactory.new
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  # Calulates the euclidean distance between two points and converst the units to output units
  def euclidean_distance(point1, point2)
    dist = GisService.convert_distance(point1.euclidean_distance(point2), @input_unit, @output_unit)
  end
  
  def from_wkt(wkt)
    Rails.logger.debug "WELL_KNOWN_TEXT '#{wkt}'"
    Geometry.from_ewkt(wkt)
  end
  
  def search_box_from_bbox(bbox)
    
    elems = bbox.split(",")
    puts elems.inspect
    
    minLon = elems[0].to_f
    minLat = elems[1].to_f
    maxLon = elems[2].to_f
    maxLat = elems[3].to_f
    
    as_polygon(minLat, minLon, maxLat, maxLon)    
  end
  
  # Creates a Polygon geometry that can be used as a search box for spatial
  # queries. Defaults to mile
  def search_box_from_point(point, radius, unit = MILE)
    lat = point.lat
    lng = point.lon
    
    # Convert input units to miles and radians
    search_distance_in_miles = GisService.convert_distance(radius, unit, MILE)
    search_distance_in_radians = search_distance_in_miles / EARTHS_RADIUS_MILES
    # Convert to decimal degrees, compensating for changes in latitude
    delta_lat = rad2deg(search_distance_in_radians)
    delta_lon = rad2deg(search_distance_in_radians/Math.cos(deg2rad(lat)))
    
    # bounding box (in degrees)
    maxLat = lat + delta_lat
    minLat = lat - delta_lat
    maxLon = lng + delta_lon
    minLon = lng - delta_lon

    as_polygon(minLat, minLon, maxLat, maxLon)    
  end

  # Converts one distance unit to another
  def self.convert_distance(val, from_unit, to_unit)
    val * from_unit.convert_to(to_unit).scalar.to_f
  end
  
  # Converts a coordinate defined as a lat,lon into a Point geometry
  def as_point(lat, lon)
    Rails.logger.debug "Creating point geometry from lat = #{lat}, lon = #{lon}"
    @geometry_factory.reset
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(lon, lat)
    @geometry_factory.end_geometry
    Rails.logger.debug "Geometry = #{@geometry_factory.geometry}"
    @geometry_factory.geometry
  end
  
  def as_polygon(minLat, minLon, maxLat, maxLon)
    Rails.logger.debug "Creating polygon geometry from (#{minLat}, {minLon}), (#{maxLat}, {maxLon})"
    @geometry_factory.reset
    @geometry_factory.begin_geometry(Polygon, @srid)
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(minLon, minLat)
    @geometry_factory.end_geometry
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(minLon, maxLat)
    @geometry_factory.end_geometry
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(maxLon, maxLat)
    @geometry_factory.end_geometry
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(maxLon, minLat)
    @geometry_factory.end_geometry
    @geometry_factory.begin_geometry(Point, @srid)
    @geometry_factory.add_point_x_y(maxLon, minLat) # ensure that the polygon is closed
    @geometry_factory.end_geometry
    @geometry_factory.end_geometry
    Rails.logger.debug "Geometry = #{@geometry_factory.geometry}"
    @geometry_factory.geometry    
  end

  protected
   
  def rad2deg(r)
    r * RAD2DEG
  end

  def deg2rad(d)
    d * DEG2RAD    
  end

end