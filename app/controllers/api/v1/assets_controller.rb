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
  end

  def index 
    total_assets = get_assets
    @assets = paginate total_assets.page(params[:page]).per(params[:page_size])
  end

  # Get a list of assets based on a set of filters
  def filter

    # We only care about retrieving the ids of the assets
    query_fields = [2]

    # Pull out the filters and convert them to hash objects
    query_filters = filter_params[:filters]
    query_filters.map!{ |f| f.to_h.symbolize_keys }

    # Create a new query and get a list of asset ids that match the filter.
    query = SavedQuery.new
    # TODO: Get the correct org list.
    # TODO: Allow filtering by org.
    query.organization_list = Organization.all.pluck(:id)
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
    base_asset_class.all
  end

  def base_asset_class
    Rails.application.config.asset_base_class_name.constantize
  end

  def filter_params
    params.permit(filters: [:query_field_id, :op, :value])
  end
end
