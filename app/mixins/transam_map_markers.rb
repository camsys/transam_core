module TransamMapMarkers

  ALPHABET = ('A'..'Z').to_a

  # create an agency-specific map marker
  def get_organization_marker(organization, render_open = false, draggable = false)
    {
      "id" => organization.id,
      "lat" => organization.latitude, 
      "lng" => organization.longitude, 
      "iconClass" => organization.organization_type.map_icon_name,
      "title" => organization.name,
      "zindex" => 1,
      "open" => render_open,
      "draggable" => false,
      "description" => render_to_string(:partial => "/organizations/organization_popup", :locals => { :organization => organization })        
    }
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
  # addr is a hash returned from the OneClick Geocoder
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
      "description" => render_to_string(:partial => "/shared/map_popup", :locals => { :place => {:icon => 'icon-building', :name => addr[:name], :address => address} })
    }
  end

end
