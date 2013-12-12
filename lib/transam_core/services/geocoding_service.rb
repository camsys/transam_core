#
# Centralizes all the geocoding logic we need
class GeocodingService

  attr_accessor :raw_address, :results, :sensor, :bounds, :components, :errors

  INCLUDED_TYPES = %w{
    airport 
    establishment
    intersection 
    natural_feature 
    park 
    point_of_interest
    premise
    route 
    street_address 
  }
  
  def initialize(attrs = {})
    # reset the current state
    reset
    @sensor = false
    @components = Rails.application.config.geocoder_components
    @bounds = Rails.application.config.geocoder_bounds
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
    
  def has_errors
    return @errors.count > 1
  end 
  
  def reverse_geocode(lat, lon)
    Rails.logger.debug "GEOCODE #{[lat, lon]}"
    # reset the current state
    reset
    @raw_address = [lat, lon]
    begin
      res = Geocoder.search(@raw_address)
      process_results(res)
    rescue Exception => e
      Rails.logger.error format_exception(e)
      @errors << e.message
    end
    [@errors.empty?, @errors, @results]
  end

  def geocode(raw_address)
    Rails.logger.debug "GEOCODE #{raw_address}"
    # reset the current state
    reset
    @raw_address = raw_address
    if raw_address.blank?
      return @results
    end
    begin
      res = Geocoder.search(@raw_address, :sensor => @sensor, :components => @components, :bounds => @bounds)
      Rails.logger.debug res.ai
      process_results(res)
    rescue Exception => e
      Rails.logger.error format_exception(e)
      @errors << e.message
    end
    [@errors.empty?, @errors, @results]
  end
  
protected
  
  def process_results(res)
    i = 0
    res.each do |alt|
      if is_valid(alt.types)
        @results << {
          :id => i,
          :name => alt.formatted_address.split(",")[0],
          :formatted_address => sanitize_formatted_address(alt.formatted_address),
          :street_address => alt.street_address,
          :city => alt.city,
          :state => alt.state_code,
          :zip => alt.postal_code,
          :lat => alt.latitude,
          :lon => alt.longitude,
          :county => alt.sub_state,
          :raw => alt
        }
        i += 1
      end
    end    
  end    
  
  # Google puts the country designator into the formatted address. We don't want this so we chomp the
  # end of the address string if the designator is there
  def sanitize_formatted_address(addr)
    if addr.include?(", USA")
      return addr[0..-6]
    else
      return addr
    end    
  end
  
  # Filters addresses returned by Google to only those we want to consider
  def is_valid(addr_types)
    addr_types.each do |addr_type|
      if INCLUDED_TYPES.include?(addr_type)
        return true
      end
    end
    return false;
  end
  
  def reset
    @results = []
    @errors = []
  end
    
end