class NeedsReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  protected
  
  def get_assets(organization, analysis_year, report_filter_type)
    
    # get the list of assets for this organization
    if report_filter_type > 0
      assets = organization.assets.where('asset_type_id = ? AND policy_replacement_year = ?', report_filter_type, analysis_year)
    else
      assets = organization.assets.where('policy_replacement_year = ?', analysis_year)
    end
    return assets
    
  end

  def get_backlog_assets(organization, report_filter_type)
    
    # get the list of assets for this agency
    if report_filter_type > 0
      assets = organization.assets.where('asset_type_id = ? AND in_backlog = ?', report_filter_type, true)
    else
      assets = organization.assets.where("in_backlog = ?", true)
    end
    return assets
    
  end
 
  # Calculates need for this year based on a list of assets
  def calc_need(assets)

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
