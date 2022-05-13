class OrganizationsController < OrganizationAwareController

  add_breadcrumb "Home",  :root_path
  add_breadcrumb "Organizations", :organizations_path

  before_action :get_org, :only => [:show, :map, :edit, :update]

  # Lock down the controller
  authorize_resource except: [:get_policies]

  # include the transam markers mixin
  include TransamMapMarkers

  INDEX_KEY_LIST_VAR    = "organization_key_list_cache_var"
  SESSION_VIEW_TYPE_VAR = 'organization_subnav_view_type'

  def get_policies
    org_id = params[:organization_id]

    result = Policy.where(organization_id: org_id).order(active: :desc).pluck(:id, :description, :active).map{|p| [p[0], "#{p[1]} #{p[2] ? '(Current)' : ''}"]}

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

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

    if params[:show_active_only].nil?
      @show_active_only = 'active'
    else
      @show_active_only = params[:show_active_only]
    end

    if @show_active_only == 'active'
      conditions << 'organizations.active = ?'
      values << true
    elsif @show_active_only == 'inactive'
      conditions << 'organizations.active = ?'
      values << false
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
    @users = @org.users.active

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
      bootstrap_toggle_fields = organization_allowable_params.select{|x| (x.to_s.include? '_ids') && !(x.to_s.include? '[]')}
      @org = org_type.class_name.constantize.new(form_params.except(*bootstrap_toggle_fields))

      if @org.save

        bootstrap_toggle_fields.each do |field|
          if form_params[field].present?
            list = form_params[field].split(',')
            @org.send("#{field.to_s}=",list)
          end
        end

        @org.updates_after_create

        # set organization role mappings
        org_type.role_mappings.each do |role|
          OrganizationRoleMapping.create(organization_id: @org.id, role_id: role.id)
        end

        # set current session to current org filter again in case new org in current filter
        set_current_user_organization_filter_(current_user, current_user.user_organization_filter) if current_user.user_organization_filter
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
      bootstrap_toggle_fields = organization_allowable_params.select{|x| (x.to_s.include? '_ids') && !(x.to_s.include? '[]')}
      if @org.update_attributes(form_params.except(*bootstrap_toggle_fields, :rta_org_credentials_attributes))
        bootstrap_toggle_fields.each do |field|
          if form_params[field].present?
            list = form_params[field].split(',')
            @org.send("#{field.to_s}=",list)
          end
        end
        # TODO: Refactor for new table
        if rta_credentials = form_params[:rta_org_credentials_attributes]
          rta_credentials.values.each do |c|
            if c[:_destroy] == "1"
              if credential = RtaOrgCredential.find_by(id: c[:id])
                unless credential.destroy
                  notify_user(:alert, "There was an issue removing RTA integration credentials:\n#{credential.errors.full_messages.join("\n")}")
                  format.html { redirect_to edit_organization_path(@org) }
                  format.json { head :no_content }
                end
              end
            elsif credential = RtaOrgCredential.find_by(id: c[:id])
              unless credential.update(name: c[:name],
                                       rta_client_id: c[:rta_client_id],
                                       rta_client_secret: c[:rta_client_secret],
                                       rta_tenant_id: c[:rta_tenant_id])
                notify_user(:alert, "There was an issue updating RTA integration credentials:\n#{credential.errors.full_messages.join("\n")}")
                format.html { redirect_to edit_organization_path(@org) }
                format.json { head :no_content }
              end
            else
              unless credential = RtaOrgCredential.create(organization: @org,
                                                          name: c[:name],
                                                          rta_client_id: c[:rta_client_id],
                                                          rta_client_secret: c[:rta_client_secret],
                                                          rta_tenant_id: c[:rta_tenant_id])
                notify_user(:alert, "There was an creating RTA integration credentials:\n#{credential.errors.full_messages.join("\n")}")
                format.html { redirect_to edit_organization_path(@org) }
                format.json { head :no_content }
              end
              unless credential.valid?
                notify_user(:alert, "There was an creating RTA integration credentials:\n#{credential.errors.full_messages.join("\n")}")
                format.html { redirect_to edit_organization_path(@org) }
                format.json { head :no_content }
              end
            end
          end
        end
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
