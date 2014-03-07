# 
# Abstract controller that is used as the base class
# for any concrete controllers that are based on an asset
#
class AssetAwareController < OrganizationAwareController
  # set the @asset variable before any actions are invoked
  before_filter :get_asset

  # From the application config    
  MAX_RETURNS_FOR_SEARCH = Rails.application.config.ui_search_items
        
  # default is to always generate typed assets (eg vehicle, railcar etc) rather
  # than untyped (asset) assets 
  RENDER_TYPED_ASSETS = true
          
  # returns details for an asset subtype using an ajax query
  def details
    @asset_subtype = AssetSubtype.find(params[:asset_subtype])

    respond_to do |format|
      format.js 
      format.json { render :json => @asset_subtype.to_json }
    end
    
  end    
  
  # Returns a JSON array of matching asset subtypes based on a typeahead name or description
  def filter
    
    asset_type = params[:asset_type]
    query = params[:query]
    query_str = "%" + query + "%"
    Rails.logger.debug query_str
    
    matches = []
    if asset_type.blank? || asset_type == '0'
      subtypes = AssetSubtype.where("name LIKE ? OR description LIKE ?", query_str, query_str)
    else
      subtypes = AssetSubtype.where("asset_type_id = ? AND (name LIKE ? OR description LIKE ?)", asset_type, query_str, query_str)
    end
    subtypes.each do |subtype|
      matches << {
        "id" => subtype.id,
        "name" => subtype.name
      }
    end

    respond_to do |format|
      format.js { render :json => matches.to_json }
      format.json { render :json => matches.to_json }
    end

  end
          
protected
  
  def render_typed_assets
    RENDER_TYPED_ASSETS
  end
  
  # returns the asset that has been selected by the user. The asset musst
  # belong to the users' selected agency. The query returns nil if the asset
  # is not found in the agencies asset list.
  #
  # if convert == true a typed version of the asset is returned
  # otherwise a base class asset is returned
  # 
  def get_selected_asset(convert=true)
    selected_asset = @organization.assets.find_by_object_key(params[:inventory_id]) unless params[:inventory_id].blank?
    if convert
      asset = get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    return asset
  end
  
  # returns the typed version of the asset
  def get_typed_asset(asset)
    if asset
      class_name = asset.asset_type.class_name
      klass = Object.const_get class_name
      o = klass.find(asset.id)
      # puts o.inspect
      return o
    end
  end
    
  def get_asset
    # check that the asset is owned by the agency
    @asset = get_selected_asset(render_typed_assets) 
    if @asset.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_index_url)
      return      
    end    
  end

end
