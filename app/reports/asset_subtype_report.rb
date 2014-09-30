class AssetSubtypeReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def summarize(assets, subtypes)

    a = [] 
    labels = ['Asset Subtype', 'Count']

    subtypes.each do |x|
      count = assets.where("assets.asset_subtype_id = ?", x.id).count
      a << [x.name, count] unless count == 0
    end
        
    return {:labels => labels, :data => a}    
  end
  
  def get_data_from_collection(assets)
    summarize(assets, AssetSubtype.all)
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
    
    assets = Asset.where('assets.organization_id IN (?)', organization_id_list)

    return summarize(assets, subtypes)

  end
  
end
