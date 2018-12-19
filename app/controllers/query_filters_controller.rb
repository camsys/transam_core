class QueryFiltersController < TransamController
  # TODO: Lock down the controller
  # authorize_resource

  def show

  end

  def render_new
    @query_field = QueryField.find_by_id(params[:query_field_id])
  end
end
