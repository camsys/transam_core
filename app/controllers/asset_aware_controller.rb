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

    query = params[:query]
    query_str = "%" + query + "%"
    Rails.logger.debug query_str

    matches = []
    assets = Asset.where("organization_id in (?) AND (asset_tag LIKE ? OR object_key LIKE ? OR description LIKE ?)", @organization_list, query_str, query_str, query_str)
    assets.each do |asset|
      matches << {
        "id" => asset.object_key,
        "name" => "#{asset.name}: #{asset.description}"
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
    selected_asset = Asset.find_by(:organization_id => @organization_list, :object_key => params[:inventory_id]) unless params[:inventory_id].blank?
    if convert
      asset = get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    return asset
  end

  # returns the typed version of the asset
  def get_typed_asset(asset)
    Asset.get_typed_asset(asset)
  end

  def get_asset
    # check that the asset is owned by the agency
    @asset = get_selected_asset(render_typed_assets)
    if @asset.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(root_url)
      return
    end
  end

end
