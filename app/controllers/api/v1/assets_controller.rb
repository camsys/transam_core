class Api::V1::AssetsController < Api::ApiController
  # Given asset object key, look up asset profile
  # GET /assets/{id}
  def show
    @asset = get_selected_asset(params[:id])
    unless @asset
      @status = :fail
      @data = {id: "Asset #{params[:id]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
    render status: 200, json: json_response(:success, data: @asset)
  end

  def index 
    total_assets = get_assets
    data = {count: total_assets.count, assets: total_assets.map { |a| a.as_json }}
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
    assets = query.data.map{ |i| base_asset_class.find(i["id"]).as_json }
    render json: {data: {count: query.data.size, assets: assets}}
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

  def get_assets
    # TODO: filtering
    #base_asset_class.all
    orgs = current_user.viewable_organizations
    base_asset_class.where(organization: orgs)
  end

  def base_asset_class
    Rails.application.config.asset_base_class_name.constantize
  end

  def query_params
    params.require(:query).permit(filters: [:query_field_id, :op, :value], orgs: [])
  end
end
