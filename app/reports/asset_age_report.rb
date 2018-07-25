class AssetAgeReport < AbstractReport

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
    
    a = []
    asset_counts = []
    labels = ['Age (Years)']

    if report_filter_type > 0
      asset_type = AssetType.find_by_id(report_filter_type)
      labels << asset_type.name
    else
      AssetType.all.each do |at|
        count = TransamAsset.where('transam_assets.organization_id IN (?) AND transam_assets.asset_subtype_id = ?', organization_id_list, at.id).count
        asset_counts << count
        labels << at.name unless count == 0
      end
    end
            
    (1..MAX_REPORTING_YEARS).each do |year|
      counts = []
      counts << "#{year}"
      manufacture_year = year.year.ago.year
      if report_filter_type > 0
        counts << TransamAsset.where("transam_assets.organization_id IN (?) AND transam_assets.asset_subtype_id = ? AND transam_assets.manufacture_year = ?", organization_id_list, report_filter_type, manufacture_year).count
      else
        AssetType.all.each_with_index do |type, idx|
          counts << TransamAsset.where("transam_assets.organization_id IN (?) AND transam_assets.asset_subtype_id = ? AND manufacture_year = ?", organization_id_list, type.id, manufacture_year).count unless asset_counts[idx] == 0
        end
      end
      a << counts
    end

    # get the bucket for MAX_YEARS+ years old
    year = MAX_REPORTING_YEARS
    counts = []
    counts << "+#{year}"
    manufacture_year = MAX_REPORTING_YEARS.year.ago.year
    if report_filter_type > 0
      counts << TransamAsset.where("transam_assets.organization_id IN (?) AND transam_assets.asset_subtype_id = ? AND transam_assets.manufacture_year < ?", organization_id_list, report_filter_type, manufacture_year).count
    else
      AssetType.all.each_with_index do |type, idx|
        counts << TransamAsset.where("transam_assets.organization_id IN (?) AND transam_assets.asset_subtype_id = ? AND transam_assets.manufacture_year < ?", organization_id_list, type.id, manufacture_year).count unless asset_counts[idx] == 0
      end
    end
    a << counts
        
    return {:labels => labels, :data => a}

  end
  
end
