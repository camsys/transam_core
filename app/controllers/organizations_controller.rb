class OrganizationsController < OrganizationAwareController

  add_breadcrumb "Home",  :root_path
  add_breadcrumb "Organizations", :organizations_path

  before_filter :get_org, :only => [:show, :map, :edit, :update]

  # include the transam markers mixin
  include TransamMapMarkers

  INDEX_KEY_LIST_VAR    = "organization_key_list_cache_var"
  SESSION_VIEW_TYPE_VAR = 'organization_subnav_view_type'

  # GET /asset
  # GET /asset.json
  def index
    # Start to set up the query
    conditions  = []
    values      = []

    @organization_type_id = params[:organization_type_id]
    unless @organization_type_id.blank?
      @organization_type_id = @organization_type_id.to_i
      conditions << 'organization_type_id = ?'
      values << @organization_type_id

      add_breadcrumb OrganizationType.find(@organization_type_id).name.pluralize(2), organizations_path(:organization_type_id => @organization_type_id)
    end

    conditions << 'id IN (?)'
    values << @organization_list

    @organizations = Organization.where(conditions.join(' AND '), *values)

    # cache the set of asset ids in case we need them later
    cache_list(@organizations, INDEX_KEY_LIST_VAR)

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

    if cannot? :read, @org
      redirect_to '/403'
      return
    end

    add_breadcrumb @org.organization_type.name.pluralize(2), organizations_path(:organization_type_id => @org.organization_type.id)
    add_breadcrumb @org.short_name

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@org, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : organization_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : organization_path(@next_record_key)

    @organizations = []
    @organizations << @org
    @markers = generate_map_markers(@organizations, true)

    # get the data for the tabs
    @users = @org.users

    if @org.try(:assets)
      rep = AssetSubtypeReport.new
      @asset_data = rep.get_data_from_collection(@org.assets)
      @total_assets = @org.assets.count
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @org }
    end
  end

  def new

    add_breadcrumb 'New', new_organization_path

    # TODO expand to allow creation of any/most org types

    org_type = OrganizationType.find_by(id: params[:organization_type_id])

    if org_type
      @org = org_type.class_name.constantize.new
    else
      redirect_to organizations_path, notice: 'Organization cannot be created without an organization type.'
    end
  end

  def create

    org_type = OrganizationType.find_by(id: params[:organization][:organization_type_id])
    if org_type
      @org = org_type.class_name.constantize.new(form_params)

      if @org.save

        @org.updates_after_create

        # set organization role mappings
        org_type.role_mappings.each do |role|
          OrganizationRoleMapping.create(organization_id: @org.id, role_id: role.id)
        end

        # set current session to current org filter again in case new org in current filter
        set_current_user_organization_filter_(current_user, current_user.user_organization_filter)
        get_organization_selections

        redirect_to organization_path(@org), notice: 'Organization was successfully created.'
      else
        render :new
      end
    end
  end

  # Edit simply returns the selected organization
  def edit
    if @org.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url
      return
    end

    add_breadcrumb @org.organization_type.name.pluralize(2), organizations_path(:organization_type_id => @org.organization_type.id)
    add_breadcrumb @org.short_name, organization_path(@org)
    add_breadcrumb "Update"

    @page_title = "Update: #{@org.name}"
  end

  def update

    if @org.nil?
      notify_user(:alert, "Record not found.")
      redirect_to organizations_url
      return
    end

    add_breadcrumb @org.organization_type.name.pluralize(2), organizations_path(:organization_type_id => @org.organization_type.id)
    add_breadcrumb @org.short_name, organization_path(@org)
    add_breadcrumb "Update"

    respond_to do |format|
      if @org.update_attributes(form_params)
        notify_user(:notice, "#{@org.name} was successfully updated.")
        format.html { redirect_to organization_url(@org) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @org.errors, :status => :unprocessable_entity }
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
  def get_org
    if params[:id].nil?
      org = current_user.organization
    else
      org = Organization.find_by(:short_name => params[:id])
    end
    if org.present?
      @org = get_typed_organization(org)
    else
      redirect_to '/404'
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:organization).permit(organization_allowable_params)
  end

end
