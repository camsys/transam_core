class ReportsController < OrganizationAwareController
    
  SESSION_VIEW_TYPE_VAR = 'reports_subnav_view_type'
      
  def index
    
    @page_title = 'Reports'
    
    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
    
    @reports = Report.all
        
  end

  # renders a dashboard detail page. Actual details depends on the id parameter passed
  # from the view
  def show
    
    # load this report and create the report instance 
    @report = Report.find(params[:id])

    if @report
      @report_view = @report.view_name
      @page_title = @report.name
      
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(current_user, params)
      
      # see if we need to load the layout or if it is a partial
      if params[:partial]
        render :layout => false
        return
      end
      
      respond_to do |format|
        format.html
      end
    end
  end
  
end
