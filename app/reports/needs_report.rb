class NeedsReport < AbstractReport

  # Include the fiscal year mixin
  include FiscalYear

  def initialize(attributes = {})
    super(attributes)
  end    
  
  protected
  
  def get_assets(organization_id_list, analysis_year, report_filter_type)
    
    # get the list of assets for this organization
    if report_filter_type > 0
      assets = Asset.where('assets.organization_id IN (?) AND assets.asset_type_id = ? AND assets.policy_replacement_year = ?', organization_id_list, report_filter_type, analysis_year)
    else
      assets = Asset.where('assets.organization_id IN (?) AND assets.policy_replacement_year = ?', organization_id_list, analysis_year)
    end
    return assets
    
  end

  def get_backlog_assets(organization_id_list, report_filter_type)
    
    # get the list of assets for this agency
    if report_filter_type > 0
      assets = Asset.where('assets.organization_id IN (?) AND assets.asset_type_id = ? AND assets.in_backlog = ?', organization_id_list, report_filter_type, true)
    else
      assets = Asset.where("assets.organization_id IN (?) AND assets.in_backlog = ?", organization_id_list, true)
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
