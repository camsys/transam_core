class Api::V1::AssetEventTypesController < Api::ApiController
  def index
    event_types = []
    AssetEventType.all.each do |event_type|
      event_types << {name: event_type.name, id: event_type.id, allowable_params: event_type.class_name.constantize.allowable_params} 
    end
    render json: json_response(:success, data: event_types)
  end
end