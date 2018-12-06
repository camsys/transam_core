class Api::V1::AssetsController < Api::ApiController
  # Given asset object key, look up asset profile
  # GET /assets/{id}
  def show
    @asset = get_selected_asset(params[:id])
    unless @asset
      @status = :fail
      @data = {id: "Asset #{params[:id]} not found."}
      render status: :not_found, , json: json_response(:fail, data: @data)
    end
  end

  def index
    total_assets = get_assets
    @assets = paginate total_assets.page(params[:page]).per(params[:page_size])
  end

  private

  def get_selected_asset(asset_id, convert=true)
    # TODO: add access control (e.g., viewable_organizations)

    selected_asset = base_asset_class.find_by(:object_key => asset_id) unless asset_id.blank?
    
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
end
