class QueryFiltersController < OrganizationAwareController
  # TODO: Lock down the controller
  # authorize_resource

  def render_new
    @query_filter = QueryFilter.find_by_id(params[:query_filter_id])
    if @query_filter
      @query_field = @query_filter.query_field
      # first check if this is a hidden filter
      # if so, then need to get the main field
      main_field = QueryField.where(pairs_with: @query_field.name).first
      if main_field
        @query_field = main_field
        @pairs_with_filter = @query_filter
        @query_filter = nil
      else
        if @query_field.pairs_with
          # check if pairs_with field filter exist
          @pairs_with_filter = @query_filter.saved_query.query_filters.joins(:query_field).where(query_fields: {name: @query_field.pairs_with}).first
        end
      end
    else
      @query_field = QueryField.find_by_id(params[:query_field_id])
    end
  end

  # typeahead json response for manufacturer filter
  def manufacturers
    assets = TransamAsset.where(organization_id: @organization_list)
    manufacturers = assets.joins(:manufacturer)
      .where.not(manufacturer_id: nil)
      .where.not(manufacturers: {name: 'Other'})
      .pluck("manufacturers.id, manufacturers.name").uniq.map{|d| {id: d[0], name: d[1]}}

    idx = 0 # indicate other_manufacturers
    other_manufacturers = assets.where.not(other_manufacturer: [nil, ""]).pluck(:other_manufacturer).uniq.map{|name| 
      idx -= 1
      {id: idx, name: name}
    }
    
    render json: (manufacturers + other_manufacturers).sort_by{|d| d[:name]}
  end

  # typeahead json response for manufacturer model filter
  def manufacturer_models
    assets = TransamAsset.where(organization_id: @organization_list)
    manufacturer_models = assets.joins(:manufacturer_model)
      .where.not(manufacturer_model_id: nil)
      .where.not(manufacturer_models: {name: 'Other'})
      .pluck("manufacturer_models.id, manufacturer_models.name").uniq.map{|d| {id: d[0], name: d[1]}}

    idx = 0 # indicate other_manufacturers
    other_manufacturer_models = assets.where.not(other_manufacturer_model: [nil, ""]).pluck(:other_manufacturer_model).uniq.map{|name| 
      idx -= 1
      {id: idx, name: name}
    }
    
    render json: (manufacturer_models + other_manufacturer_models).sort_by{|d| d[:name]}
  end

  def vendors
    assets = TransamAsset.where(organization_id: @organization_list)

    vendors = Organization.pluck(:id, :name).uniq.map{|d| {id: d[0], name: d[1]}}

    idx = 0 # indicate other
    other_vendors = assets.where.not(other_vendor: nil).pluck(:other_vendor).uniq.map{|name| 
      idx -= 1
      {id: idx, name: name}
    }
    
    render json: (vendors + other_vendors).sort_by{|d| d[:name]}
  end
end
