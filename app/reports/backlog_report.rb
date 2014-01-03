class BacklogReport < AbstractReport

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
        
    # get the list of assets for this agency
    if report_filter_type > 0
      assets = organization.assets.where('asset_type_id = ? AND in_backlog = ?', report_filter_type, true).order('asset_type_id, asset_subtype_id')
    else
      assets = organization.assets.where("in_backlog = ?", true).order('asset_type_id, asset_subtype_id')
    end

    a = {}
    assets.find_each do |asset|
      # see if this asset sub type has been seen yet
      if a.has_key?(asset.asset_subtype)
        report_row = a[asset.asset_subtype]
      else
        report_row = AssetSubtypeReportRow.new(asset.asset_subtype)
        a[asset.asset_subtype] = report_row
      end
      # get the replacement cost for this item based on the current policy
      report_row.add(asset)
      end
    return a          
  end
  
end
