class Api::V1::AssetsController < Api::ApiController
  # Given asset object key, look up asset profile
  # GET /assets/{id}
  def show
    @asset = get_selected_asset(params[:id])
    #TODO: Should be able to use cancan here e.g., authorize! :show @asset. However, this does not acknowledge Orgs
    unless @asset and @asset.viewable_by? current_user
      @status = :fail
      render status: :not_found, json: json_response(:fail, message: "Asset #{params[:id]} not found.")
    else
      render status: 200, json: json_response(:success, data: @asset.api_json(include_events: include_events))
    end
  end

  def index 
    total_assets = get_assets
    data = {count: total_assets.count, assets: total_assets}
    render status: 200, json: json_response(:success, data: data)
  end

  # Get a list of assets based on a set of filters
  def filter
    # We only care about retrieving the ids of the assets.
    query_fields = [2]

    # Pull out the orgs and ensure that they are viewable by the current_user
    orgs = query_params[:orgs]
    viewable_orgs = current_user.viewable_organizations.pluck(:id)
    orgs = orgs.blank? ? viewable_orgs : (viewable_orgs & orgs)

    # Pull out the filters and convert them to hash Objects
    query_filters = query_params[:filters]
    query_filters.map!{ |f| f.to_h.symbolize_keys }

    # Create a new query and get a list of asset ids that match the filter.
    query = SavedQuery.new
    query.organization_list = orgs
    query.parse_query_fields query_fields, query_filters

    # Convert those asset ids into Asset Objects
    if summary_only 
      assets = query.data.map{ |i| base_asset_class.find(i["id"]).summary_api_json }
    else
      assets = query.data.map{ |i| convert(base_asset_class.find(i["id"])).api_json }
    end
    render json: {data: {count: query.data.size, assets: assets}}
  end

  def update
    @asset = get_selected_asset(params[:id])
    #TODO: This raises a 500 error. It should raise 401: Unauthorized
    authorize! :update, @asset
    if @asset 
      @asset.update!(asset_params(@asset))
      Rails.cache.delete("inventory_api" + @asset.object_key)
      render status: 200, json: json_response(:success, data: @asset.api_json)
    else
      render status: :not_found, json: json_response(:fail, message: "Asset #{params[:id]} not found.")
    end
  end

  private

  def get_selected_asset(asset_id, convert=true, use_id=false)
    # TODO: add access control (e.g., viewable_organizations)

    if use_id
      selected_asset = base_asset_class.find(asset_id) unless asset_id.blank?
    else
      selected_asset = base_asset_class.find_by(:object_key => asset_id) unless asset_id.blank?
    end
    
    if convert
      asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    
    asset
  end

  # Get the most specific version of the asset
  def convert asset 
    Rails.application.config.asset_base_class_name.constantize.get_typed_asset(asset)
  end

  def get_assets
    orgs = current_user.viewable_organizations
    TransamAsset.where(organization: orgs).map{ |a| a.summary_api_json }
  end

  def base_asset_class
    Rails.application.config.asset_base_class_name.constantize
  end

  def query_params
    params.require(:query).permit(filters: [:query_field_id, :op, :value], orgs: [])
  end

  def asset_params(asset)
    params.require(:asset).permit(asset.allowable_params)
  end

  def include_events
    params[:include_events].to_i == 1
  end

  def summary_only
    params[:summary_only].to_i == 1
  end
end
