class Api::V1::QueryFieldsController < Api::ApiController
  def index
    category = params[:query_category_id]
    if category
      query_fields = QueryField.where(query_category_id: category).map{ |qf| qf.api_json }
    else
      query_fields = QueryField.all.map{ |qf| qf.api_json }
    end
    render status: 200, json: json_response(:success, data: query_fields)
  end
end