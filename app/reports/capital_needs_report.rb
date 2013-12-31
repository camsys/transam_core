class CapitalNeedsReport < NeedsReport

  BACKLOG_KEY = 'Backlog'
  
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
        
    # Asset needs by year
    analysis_year = Date.today.year
    last_year = analysis_year + MAX_NEEDS_REPORTING_YEARS
    a = {}
    report_row = BasicReportRow.new(BACKLOG_KEY)
    a[BACKLOG_KEY] = report_row
    # get the backlog assets
    assets = get_backlog_assets(current_user, report_filter_type)
    assets.find_each do |asset|
      report_row.add(asset)
    end
        
    (analysis_year..last_year).each do |year|
      report_row = BasicReportRow.new(year)
      a[year] = report_row
      # get the assets for this analysis year
      assets = get_assets(current_user, year, report_filter_type)
      assets.find_each do |asset|
        report_row.add(asset)
      end
    end
    
    return a          
  end
  
end
