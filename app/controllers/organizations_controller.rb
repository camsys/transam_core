class OrganizationsController < OrganizationAwareController
  before_filter :check_for_cancel, :only => [:create, :update]
  
  # include the transam markers mixin
  include TransamMapMarkers
  
  SESSION_VIEW_TYPE_VAR = 'organization_subnav_view_type'
    
  # GET /asset
  # GET /asset.json
  def index
    @organizations = current_user.organizations

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
    
    # If we are building a map, make sure we get the map artifacts
    if @view_type == VIEW_TYPE_MAP
      @markers = generate_map_markers(@organizations)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @organizations }
    end
  end
  
  def show
    
    if @organization.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url 
      return
    end
    
    @page_title = @organization.name
    @disabled = true
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @organization }
    end
    
  end

  def map

    if @organization.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url 
      return
    end
    
    @page_title = @organization.name
    @organizations = []
    @organizations << @organization
    @markers = generate_map_markers(@organizations, true)
                  
    respond_to do |format|
      format.html # map.html.erb
      format.json { render @markers }
    end
    
  end
  
  # Edit simply returns the selected organization
  def edit
    if @organization.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url 
      return
    end
    @page_title = "Update"    
  end

  def update
    if @organization.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url 
      return
    end

    respond_to do |format|
      if @organization.update_attributes(form_params)
        notify_user(:notice, "#{@organization.name} was successfully updated.")
        format.html { redirect_to organization_url(@organization) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @organization.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
  #
  # generate an array of map markers for use with the leaflet plugin
  #
  def generate_map_markers(organizations_array, render_open = false)
    objs = []
    organizations_array.each do |org|
      objs << get_organization_marker(org, render_open) unless org.latitude.nil?
    end
    return objs.to_json    
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
      
  # Returns the agency that has been selected by the user. The agency must
  # be user's agency or one of its member agencies. 
  def get_organization
    if params[:id].nil?
      org = current_user.organization
    else
      org = current_user.organizations.find_by_short_name(params[:id])
    end
    if org
      @organization = get_typed_organization(org)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:organization).permit(organization_allowable_params)
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      @organization = get_organization
      redirect_to organization_url(@organization)
    end
  end
  
end
