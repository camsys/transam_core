class ReportsController < OrganizationAwareController
    
  SESSION_VIEW_TYPE_VAR = 'reports_subnav_view_type'
      
  def index
    
    @page_title = 'Reports'
    
    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
    
    @reports = Report.all
        
  end

  def load

    # load this report and create the report instance 
    @report = Report.find(params[:id])
    if @report.nil?
      notify_user(:alert, "Can't find report.")
    end
    
    report_instance = @report.class_name.constantize.new
    @data = report_instance.get_data(@organization, params)

    respond_to do |format|
      format.js 
      format.json { render :json => @data.to_json }
    end
    
  end
  
  # renders a dashboard detail page. Actual details depends on the id parameter passed
  # from the view
  def show

    # load this report and create the report instance 
    @report = Report.find(params[:id])

    if @report.nil?
      notify_user(:alert, "Record not found!")
      redirect_to reports_url
      return
    end
    

    if @report
      @report_view = @report.view_name
      @page_title = @report.name
      
      report_instance = @report.class_name.constantize.new
      @data = report_instance.get_data(@organization, params)
      
      respond_to do |format|
        format.html
      end
    end
  end
  
end
