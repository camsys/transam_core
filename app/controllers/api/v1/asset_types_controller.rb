class Api::V1::AssetTypesController < Api::ApiController
  def index
    asset_types = []
    Rails.application.config.asset_seed_class_name.constantize.all.each do |asset_type|
      asset_types << {name: asset_type.name, id: asset_type.id, allowable_params: asset_type.class_name.constantize.new.allowable_params} 
    end
  
    render json: json_response(:success, data: asset_types)

  end
end