class ReportsController < OrganizationAwareController

  before_filter :get_report, :only => [:show, :load]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Reports", :reports_path

  SESSION_VIEW_TYPE_VAR = 'reports_subnav_view_type'

  def index

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    @reports = []
    Report.all.each do |rep|
      if current_user.is_in_roles? rep.role_names
        @reports << rep
      end
    end

  end

  def load

    report_instance = @report.class_name.constantize.new
    # inject the sql for the report into the params
    params[:sql] = @report.custom_sql unless @report.custom_sql.blank?
    # get the report data
    @data = report_instance.get_data(@organization_list, params)

    respond_to do |format|
      format.js
      format.json { render :json => @data.to_json }
    end

  end

  def show

    @report_filter_type = params[:report_filter_type]
    @asset_types = []
    AssetType.all.each do |at|
      count = Asset.where('assets.organization_id IN (?) AND assets.asset_type_id = ?', @organization_list, at.id).count
      if count > 0
        @asset_types << [at.name, at.id]
      end
    end

    if @report
      @report_view = @report.view_name
      add_breadcrumb @report.name

      report_instance = @report.class_name.constantize.new
      # inject the sql for the report into the params
      params[:sql] = @report.custom_sql unless @report.custom_sql.blank?
      # get the report data
      @data = report_instance.get_data(@organization_list, params)

      respond_to do |format|
        format.html
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Returns the selected report
  def get_report
    # load this report and create the report instance
    report = Report.find(params[:id])
    # check that the current use is authorized to view the report
    unless report.nil?
      if current_user.is_in_roles? report.role_names
        @report = report
      end
    end
    if @report.nil?
      notify_user(:alert, "Can't find report.")
      redirect_to reports_url
      return
    end
  end
end
