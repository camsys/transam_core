class Api::V1::AssetClassesController < Api::ApiController
  def index
    asset_classes = []
    Rails.application.config.asset_seed_class_name.constantize.all.each do |asset_class|
      asset_classes << {name: asset_class.name, id: asset_class.id, allowable_params: asset_class.class_name.constantize.new.try(:allowable_params)} 
    end
  
    render json: json_response(:success, data: asset_classes)

  end
end