class SystemConfigsController < OrganizationAwareController
  add_breadcrumb 'Home', :root_path

  before_action :set_system_config
  before_action :set_paper_trail_whodunnit

  # GET /system_configs/1
  def show
    add_breadcrumb 'System Config', @system_config
  end

  def fiscal_year_rollover
    add_breadcrumb 'Client Admin Interface', @system_config
    add_breadcrumb 'System Rollover', fiscal_year_rollover_system_config_path(@system_config)
  end

  # GET /system_configs/1/edit
  def edit
    add_breadcrumb 'System Config', @system_config
    add_breadcrumb 'Edit', edit_system_config_path(@system_config)
  end

  # PATCH/PUT /system_configs/1
  def update
    if @system_config.update(system_config_params)
      redirect_back(fallback_location: system_config_path(@system_config), notice: 'System config was successfully updated.')
    else
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_config
      @system_config = SystemConfig.instance
    end

    # Only allow a trusted parameter "white list" through.
    def system_config_params
      params.require(:system_config).permit(SystemConfig.allowable_params)
    end

end
