module TransamMapHelper
  
  # From the application config    
  TILE_PROVIDER = SystemConfig.instance.map_tile_provider
  
  ALPHABET = ('A'..'Z').to_a

  # Return the tile provider
  def get_map_tile_provider
    TILE_PROVIDER
  end
  
  # Returns a formatted string for displaying a map marker image that includes a A,B,C, etc. designator.
  #
  # index is a positive integer x, x >= 0 that corresponds to the index of the object in
  # an abitarily ordered list
  #
  # type is an enumeration
  #   0 = a start candidate location
  #   1 = a stop candidate location
  #   2 = a place candidate
  def get_candidate_list_item_image(index, type)
    if type == "0"
      return 'http://maps.google.com/mapfiles/marker_green' + ALPHABET[index] + ".png"
    elsif type == "1"
      return 'http://maps.google.com/mapfiles/marker' + ALPHABET[index] + ".png"
    else
      return 'http://maps.google.com/mapfiles/marker_yellow' + ALPHABET[index] + ".png"
    end
  end
  
  # create a map marker for a GeolocatableAsset instance
  #
  # place is an instance of the Place class
  # id is a unique identifier for the place that could be a string
  # icon is a named icon from the leafletmap_icons.js file
  def get_map_marker(geolocatable_asset, id, draggable=false, zindex = 0, icon=nil)
    if icon.nil?
      icon = geolocatable_asset.asset_type.map_icon_name
    end
    {
      "id" => id,
      "lat" => geolocatable_asset.geometry.lat,
      "lng" => geolocatable_asset.geometry.lon,
      "zindex" => zindex,
      "name" => geolocatable_asset.name,
      "iconClass" => icon,
      "draggable" => draggable,
      "title" => geolocatable_asset.asset_subtype.name,
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :asset => geolocatable_asset})
    }
  end
  
  # create a map marker for a geocoded address
  #
  # addr is a hash returned from the TransAM Geocoder
  # id is a unique identifier for the place that could be a string
  # icon is a named icon from the leafletmap_icons.js file
  def get_addr_marker(addr, id, icon, zindex = 0)
    address = addr[:formatted_address].nil? ? addr[:address] : addr[:formatted_address]
    {
      "id" => id,
      "lat" => addr[:lat],
      "lng" => addr[:lon],
      "zindex" => zindex,
      "name" => addr[:name],
      "iconClass" => icon,
      "title" =>  address,
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'fa fa-building-o', :name => addr[:name], :address => address} })
    }
  end
  
end