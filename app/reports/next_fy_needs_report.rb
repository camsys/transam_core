class NextFyNeedsReport < NeedsReport

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
        
    analysis_year = Date.today.year + 1
    
    assets = get_assets(current_user, analysis_year, report_filter_type)
    
    return calc_need(assets)
        
  end
  
end
