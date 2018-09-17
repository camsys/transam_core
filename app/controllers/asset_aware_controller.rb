#
# Abstract controller that is used as the base class
# for any concrete controllers that are based on an asset
#
class AssetAwareController < OrganizationAwareController
  # set the @asset variable before any actions are invoked
  before_action :get_asset

  # From the application config
  MAX_RETURNS_FOR_SEARCH = Rails.application.config.ui_search_items

  # default is to always generate typed assets (eg vehicle, railcar etc) rather
  # than untyped (asset) assets
  RENDER_TYPED_ASSETS = true

  # returns details for an asset subtype using an ajax query
  # NOT USED
  def details
    @asset_subtype = AssetSubtype.find(params[:asset_subtype])

    respond_to do |format|
      format.js
      format.json { render :json => @asset_subtype.to_json }
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
    selected_asset = Rails.application.config.asset_base_class_name.constantize.find_by(:organization_id => @organization_list, :object_key => params[:inventory_id]) unless params[:inventory_id].blank?
    if convert
      asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    return asset
  end

  def get_asset
    # check that the asset is owned by the agency
    @asset = get_selected_asset(render_typed_assets)
    if @asset.nil?
      if  TransamAsset.find_by(:organization_id => current_user.user_organization_filters.system_filters.first.get_organizations.map{|x| x.id}, :object_key => params[:id]).nil?
        redirect_to '/404'
      else
        notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
        redirect_to inventory_index_path
      end
      return
    end
  end

end
