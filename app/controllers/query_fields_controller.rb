class QueryFieldsController < TransamController
  # TODO: Lock down the controller
  # authorize_resource

  respond_to :json

  def index
    @query_fields = QueryField.visible.order(:label)
    unless params[:query_category_id].blank?
      @query_fields = @query_fields.by_category_id(params[:query_category_id])
    end
    
    render json: @query_fields 
  end
end
