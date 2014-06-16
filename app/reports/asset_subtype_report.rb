class AssetSubtypeReport < AbstractReport

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
    
    a = [] 
    labels = ['Asset Subtype', 'Count']

    subtypes.each do |x|
      count = Asset.where("assets.organization_id IN (?) AND assets.asset_subtype_id = ?", organization_id_list, x.id).count
      a << [x.name, count] unless count == 0
    end
        
    return {:labels => labels, :data => a}

  end
  
end
