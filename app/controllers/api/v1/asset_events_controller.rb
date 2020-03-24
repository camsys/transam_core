class Api::V1::AssetEventsController < Api::ApiController
  before_action :set_asset_event

  # DELETE /asset_events/1.json
  def destroy
    unless @asset_event.destroy
      @status = :fail
      @message  = "Unable to destroy asset event due the following error: #{@asset_event.errors.messages}"
      render status: 400, json: json_response(:fail, message: @message)
    end
  end

  def set_asset_event
    @asset_event = AssetEvent.find_by(object_key: params[:id])

    unless @asset_event
      @status = :fail
      @data = {id: "Asset event #{params[:id]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end
end