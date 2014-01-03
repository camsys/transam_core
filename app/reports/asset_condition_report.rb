class AssetConditionReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(current_user, params)

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
        count = current_user.organization.assets.where("asset_type_id = ? AND last_reported_condition_type_id = ?", report_filter_type, x.id).count
      else
        count = current_user.organization.assets.where("last_reported_condition_type_id = ?", x.id).count
      end
      a << [x.name, count]
    end
        
    return {:labels => labels, :data => a}

  end
  
end
