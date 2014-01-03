class AssetSubtypeReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization, params)

    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end

    if report_filter_type == 0
      subtypes = AssetSubtype.all
    else
      subtypes = AssetSubtype.find_by_asset_type_id(report_filter_type)    
    end
    
    a = [] 
    labels = ['Asset Subtype', 'Count']

    subtypes.each do |x|
      count = organization.assets.where("asset_subtype_id = ?", x.id).count
      a << [x.name, count]
    end
        
    return {:labels => labels, :data => a}

  end
  
end
