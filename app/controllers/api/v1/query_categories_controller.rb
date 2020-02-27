class Api::V1::QueryCategoriesController < Api::ApiController
  def index
    query_categories = QueryCategory.all.map{ |o| {id: o.id, name: o.name}}
    render status: 200, json: json_response(:success, data: query_categories)
  end
end
