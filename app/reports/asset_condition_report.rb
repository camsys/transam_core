class AssetConditionReport < AbstractReport

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
    labels = ['Condition', 'Count']

    ConditionType.all.each do |x|
      if report_filter_type > 0
        count = Asset.where("assets.organization_id IN (?) AND assets.asset_type_id = ? AND assets.reported_condition_type_id = ?", organization_id_list, report_filter_type, x.id).count
      else
        count = Asset.where("assets.organization_id IN (?) AND assets.reported_condition_type_id = ?", organization_id_list, x.id).count
      end
      a << [x.name, count]
    end
        
    return {:labels => labels, :data => a}

  end
  
end
