class BacklogReport < AbstractReport

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
        
    # get the list of assets for this agency
    if report_filter_type > 0
      assets = Rails.application.config.asset_base_class_name.constantize.joins(asset_subtype: :asset_type).where(organization_id: organization_id_list, asset_types: {id: report_filter_type}, in_backlog: true).order('asset_types.id, asset_subtype_id')
    else
      assets = Rails.application.config.asset_base_class_name.constantize.where(organization_id: organization_id_list, in_backlog: true).order('asset_types.id, asset_subtype_id')
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
