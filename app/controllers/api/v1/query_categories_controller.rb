class Api::V1::QueryCategoriesController < Api::ApiController
  def index
    query_categories = QueryCategory.all.map{ |o| {id: o.id, name: o.name}}
    render status: 200, json: query_categories
  end
end
