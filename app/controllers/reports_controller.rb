class ReportsController < OrganizationAwareController

  before_action :get_report, :only => [:show, :load]

  # Lock down the controller
  #authorize_resource only: [:index, :show]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Reports", :reports_path

  SESSION_VIEW_TYPE_VAR = 'reports_subnav_view_type'

  def index

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    @reports = []

    if params[:report_type]
      active_reports = Report.active.where(report_type: params[:report_type])
    else
      active_reports = Report.active
    end

    active_reports.each do |rep|
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
    handle_show do
      respond_to do |format|
        format.html
        format.xls do
          sanitized_report_name = @report.name.gsub(" ", "_").underscore
          response.headers['Content-Disposition'] = "attachment; filename=#{@organization.short_name}_#{sanitized_report_name}.xls"
        end
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Simply calling super in a subclassed show method doesn't work because of the respond_to
  # This method does the work of setting up the report, allowing the subclass to pass
  # a different respond_to block.
  def handle_show &block

    @report_filter_type = params[:report_filter_type]
    @asset_types = []
    AssetType.active.each do |at|
      count = Rails.application.config.asset_base_class_name.constantize.where(organization_id: @organization_list, asset_subtype_id: at.id).count
      if count > 0
        @asset_types << [at.name, at.id]
      end
    end

    if @report
      @report_view = @report.view_name
      add_breadcrumb @report.name

      @report_instance = @report.class_name.constantize.new(params)
      # inject the sql for the report into the params
      params[:sql] = @report.custom_sql unless @report.custom_sql.blank?
      # get the report data
      @data = @report_instance.get_data(@organization_list, params)

      # String return value indicates an error message.
      if @data.is_a? String
        notify_user(:alert, @data)
        redirect_to report_path(@report)
      else
        yield
      end
    end
  end

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
      redirect_to '/404'
      return
    end
  end
end