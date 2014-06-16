class CustomSqlReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization_id_list, params)

    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end

    if report_filter_type == 0
      subtypes = AssetSubtype.all
    else
      subtypes = AssetSubtype.where('asset_type_id = ?', report_filter_type)
    end
    
    # Execute a SQL query against the database
    results = ActiveRecord::Base.connection.exec_query(params[:sql])
    
    a = [] 
    labels = []
    
    if results.empty?
      a = [] 
      labels = []
    else
      # Get the column names that were returned
      labels = results.columns.dup
      a = results.rows.dup
    end

    return {:labels => labels, :data => a}

  end
  
end
