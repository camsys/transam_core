class AssetAgeReport < AbstractReport

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
    
    a = []
    labels = ['Age (Years)']

    AssetType.all.each do |type| 
      labels << type.name
    end
        
    (1..(MAX_YEARS_FUTURE - 1)).each do |year|
      counts = []
      counts << year.to_s
      to_date = (year-1).year.ago
      from_date = year.year.ago
      AssetType.all.each do |type| 
        counts << Asset.where("organization_id = ? AND asset_type_id = ? AND manufacture_year BETWEEN ? AND ?", organization.id, type.id, from_date, to_date).count
      end
      a << counts
    end

    # get the bucket for MAX_YEARS+ years old
    year = MAX_YEARS_FUTURE
    counts = []
    counts << year.to_s
    to_date = 100.year.ago
    from_date = year.year.ago
    AssetType.all.each do |type| 
      counts << Asset.where("organization_id = ? AND asset_type_id = ? AND manufacture_year BETWEEN ? AND ?", organization.id, type.id, from_date, to_date).count
    end
    a << counts
        
    return {:labels => labels, :data => a}

  end
  
end
