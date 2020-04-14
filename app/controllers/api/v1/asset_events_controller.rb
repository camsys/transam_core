class Api::V1::AssetEventsController < Api::ApiController
  before_action :set_asset_event, only: [:show, :update, :destroy]
  before_action :set_asset, only: [:create]
  before_action :set_event_type, only: [:create]

  
  def show
    if @typed_event
      render status: 200, json: json_response(:success, data: @typed_event.api_json)
    else
      render status: 404, json: json_response(:fail, data: "Unable to find event.")
    end
  end

  def destroy
    unless @asset_event.destroy
      @status = :fail
      @message  = "Unable to destroy asset event due the following error: #{@asset_event.errors.messages}"
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  def update
    if @typed_event.update(form_params)
      render status: 200, json: json_response(:success, data: @typed_event.api_json)
    else
      @status = :fail
      @message  = "Unable to update asset event due the following error: #{@typed_event.errors.messages}"
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  def create
    @new_event = @asset.build_typed_event(@event_type.class_name.constantize)
    @new_event.update(new_form_params)

    if @new_event.save
      render status: 200, json: json_response(:success, data: @new_event.api_json)
    else
      @status = :fail
      @message  = "Unable to create asset event due the following error: #{@new_event.errors.messages}"
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  def set_asset_event
    @asset_event = AssetEvent.find_by(object_key: params[:id])
    @typed_event = AssetEvent.as_typed_event(@asset_event)

    unless @asset_event
      @status = :fail
      message = "Asset event #{params[:id]} not found."
      render status: :not_found, json: json_response(:fail, message: message)
    end
  end

  def set_asset
    @asset = TransamAsset.find_by(object_key: params[:asset_object_key])
    @typed_asset = TransamAsset.get_typed_asset(@asset)

    unless @asset
      @status = :fail
      message =  "Asset #{params[:asset_object_key]} not found."
      render status: :not_found, json: json_response(:fail, message: message)
    end
  end

  def set_event_type
    @event_type = AssetEventType.find(params[:asset_event_type_id])

    unless @event_type
      @status = :fail
      @data = {id: "Event type #{params[:event_type]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    else
      unless @typed_asset.event_classes.include? @event_type.class_name.constantize
        @status = :fail
        @data = {id: "Event type #{params[:event_type]} not applicable to asset #{params[:asset_id]}."}
        render status: :not_found, json: json_response(:fail, data: @data)
      end
    end
  end

  def form_params
    params.permit(AssetEvent.allowable_params + @typed_event.class.name.constantize.allowable_params - [:asset_id, :asset_event_type_id])
  end

  def new_form_params
    params.permit(AssetEvent.allowable_params + @event_type.class_name.constantize.allowable_params - [:asset_id, :asset_event_type_id])
  end
end