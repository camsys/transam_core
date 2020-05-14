class UsersController < OrganizationAwareController

  #-----------------------------------------------------------------------------
  # Protect controller methods using the cancan ability
  #-----------------------------------------------------------------------------
  authorize_resource :user, except: :popup

  #-----------------------------------------------------------------------------
  add_breadcrumb "Home",  :root_path
  add_breadcrumb "Users", :users_path

  #-----------------------------------------------------------------------------
  skip_before_action :get_organization_selections,      :only => [:authorizations]
  before_action :set_viewable_organizations,      :only => [:authorizations]


  before_action :set_user, :only => [:show, :edit, :settings, :update, :destroy, :change_password, :update_password, :profile_photo, :reset_password, :authorizations]
  before_action :check_for_cancel, :only => [:create, :update, :update_password]



  #-----------------------------------------------------------------------------
  INDEX_KEY_LIST_VAR    = "user_key_list_cache_var"
  SESSION_VIEW_TYPE_VAR = 'users_subnav_view_type'

  FILTERS_IGNORED = Rails.application.config.try(:user_organization_filters_ignored).present?

  #-----------------------------------------------------------------------------
  # GET /users
  # GET /users.json
  #-----------------------------------------------------------------------------
  def index

    @organization_id = params[:organization_id].to_i
    @search_text = params[:search_text]
    @role = params[:role].split(",") if params[:role]
    @id_filter_list = params[:ids]

    # Start to set up the query
    conditions  = []
    values      = []

    if @organization_id.to_i > 0
      conditions << 'users_organizations.organization_id = ?'
      values << @organization_id
    else
      conditions << 'users_organizations.organization_id IN (?)'
      values << @organization_list
    end


    unless @search_text.blank?
      # get the list of searchable fields from the asset class
      searchable_fields = User.new.searchable_fields
      # create an OR query for each field
      query_str = []
      first = true
      # parameterize the search based on the selected search parameter
      search_value = get_search_value(@search_text, @search_param)
      # Construct the query based on the searchable fields for the model
      searchable_fields.each do |field|
        if first
          first = false
          query_str << '('
        else
          query_str << ' OR '
        end

        query_str << "UPPER(users.#{field})"
        query_str << ' LIKE ? '
        # add the value in for this sub clause
        values << search_value.upcase
      end
      query_str << ')' unless searchable_fields.empty?

      conditions << [query_str.join]
    end

    unless @id_filter_list.blank?
      conditions << 'object_key in (?)'
      values << @id_filter_list
    end

    if params[:show_active_only].nil?
      @show_active_only = 'active'
    else
      @show_active_only = params[:show_active_only]
    end

    if @show_active_only == 'active'
      conditions << 'users.active = ?'
      values << true
    elsif @show_active_only == 'inactive'
      conditions << 'users.active = ?'
      values << false
    end

    # Get the Users but check to see if a role was selected
    @users = User.unscoped.distinct.joins(:organization).order('organizations.organization_type_id', 'organizations.short_name', :last_name).joins(:organizations).includes(:organization,:roles).where(conditions.join(' AND '), *values)

    unless @role.blank?
      all_users = @users
      @users = @users.with_role(@role[0])
      @role[1..-1].each do |r|
        @users = @users.or(all_users.with_role(r))
      end
    end

    if params[:sort] && params[:order]
      case params[:sort]
      when 'organization'
        @users = @users.reorder("organizations.short_name #{params[:order]}")
      # figure out sorting by role + privilege some other way
      # when 'role_name'
      #   @users = @users.joins(:roles).merge(Role.unscoped.order(name: params[:order]))
      # when 'privilege_names'
      #   @users = @users.joins(:roles).merge(Role.order(privilege: params[:order]))
      else
        @users = @users.reorder(params[:sort] => params[:order])
      end
    end

    # Set the breadcrumbs
    if @organization_list.count == 1
      org = Organization.find(@organization_list.first)
      add_breadcrumb org.short_name, users_path(:organization_id => org.id)
    end
    if @role.present?
      role_string = @role.kind_of?(Array) ? Role.find_by(name: @role).try(:label).try(:parameterize).try(:underscore) : @role
      add_breadcrumb role_string.titleize, users_path(:role => role_string) if role_string
    end

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    respond_to do |format|
      format.html # index.html.erb
      # format.json {
      #   render :json => {
      #     :total => @users.count,
      #     :rows => @users.limit(params[:limit]).offset(params[:offset]).collect{ |u|
      #       u.as_json.merge!({
      #            organization_short_name: u.organization.short_name,
      #            organization_name: u.organization.name,
      #            role_name: !@role.blank? && (@role.kind_of?(Array) ? !Role.find_by(name:@role.first).privilege : !Role.find_by(name: @role).privilege) ? (@role.kind_of?(Array) ? u.roles.roles.where(name: @role).last.label : u.roles.roles.find_by(name: @role).label) : u.roles.roles.last.label,
      #            privilege_names: u.roles.privileges.collect{|x| x.label}.join(', '),
      #            all_orgs: u.organizations.map{ |o| o.to_s }.join(', ')
      #       })
      #     }
      #   }
      # }

    end
  end

  #-----------------------------------------------------------------------------
  # Show the list of current sessions. Only available for admin users
  # TODO: MOST of this will be moved to a shareable module
  #-----------------------------------------------------------------------------
  def table
    count = User.all.count 
    page = (table_params[:page] || 0).to_i
    page_size = (table_params[:page_size] || count).to_i
    search = (table_params[:search])
    offset = page*page_size

    query = nil 
    if search
      searchable_columns = [:first_name, :last_name, :phone, :phone_ext, :email, :title] 
      search_string = "%#{search}%"
      org_query = Organization.arel_table[:name].matches(search_string).or(Organization.arel_table[:short_name].matches(search_string))
      query = (query_builder(searchable_columns, search_string)).or(org_query)

      # This does not work. TODO: find out why this doesn't work.
      count = User.joins(:organization).where(query).count 

      user_table = User.joins(:organization).where(query).offset(offset).limit(page_size).map{ |u| u.rowify }
    else 
      user_table = User.all.offset(offset).limit(page_size).map{ |u| u.rowify }
    end

    render status: 200, json: {count: count, rows: user_table}
  end

  def query_builder atts, search_string
    if atts.count <= 1
      return User.joins(:organziation).arel_table[atts.pop].matches(search_string)
    else
      return User.joins(:organization).arel_table[atts.pop].matches(search_string).or(query_builder(atts, search_string))
    end
  end

  #-----------------------------------------------------------------------------
  # Show the list of current sessions. Only available for admin users
  #-----------------------------------------------------------------------------
  def sessions

    key = "000000:#{TransamController::ACTIVE_SESSION_LIST_CACHE_VAR}"
    @sessions =  Rails.cache.fetch(key)
    @sessions ||= {}

  end

  #-----------------------------------------------------------------------------
  # GET /users/1
  # GET /users/1.json
  #-----------------------------------------------------------------------------
  def show

    if @user.id == current_user.id
      add_breadcrumb "My Profile"
    else
      add_breadcrumb @user.name
    end

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@user, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : user_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : user_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  #-----------------------------------------------------------------------------
  # GET /users/new
  # GET /users/new.json
  #-----------------------------------------------------------------------------
  def new

    add_breadcrumb 'New'

    @user = User.new

    respond_to do |format|
      format.html # new.html.haml this had been an erb and is now an haml the change should just be caught
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'

  end

  def authorizations
    add_breadcrumb @user, user_path(@user)
    add_breadcrumb 'Update', authorizations_user_path(@user)
  end

  #-----------------------------------------------------------------------------
  # Sends a reset password email to the user. This is an admin function
  #-----------------------------------------------------------------------------
  def reset_password

    @user.send_reset_password_instructions

    system_user = User.where(first_name: 'system', last_name: 'user').first
    message_template = MessageTemplate.find_by(name: 'User2')
    message_body =  MessageTemplateMessageGenerator.new.generate(message_template,[@user.name, "<a href='#'>Change my password</a>"]).html_safe

    msg               = Message.new
    msg.user          = system_user
    msg.organization  = system_user.organization
    msg.to_user       = @user
    msg.subject       = message_template.subject
    msg.body          = message_body
    msg.priority_type = message_template.priority_type
    msg.message_template = message_template
    msg.active     = message_template.active
    msg.save

    notify_user(:notice, "Instructions for resetting their password was sent to #{@user} at #{@user.email}")

    redirect_to user_path(@user)

  end

  #-----------------------------------------------------------------------------
  # GET /users/1/edit
  #-----------------------------------------------------------------------------
  def change_password

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Change Password'

  end

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def settings

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'
  end

  #-----------------------------------------------------------------------------
  # POST /users
  # POST /users.json
  #-----------------------------------------------------------------------------
  def create

    # Get the role_ids and privelege ids and remove them from the params hash
    # as we dont want these managed by the rails associations
    role_id = params[:user][:role_ids]
    privilege_ids = params[:user][:privilege_ids]

    # Get a new user service to invoke any business logic associated with creating
    # new users
    new_user_service = get_new_user_service
    # Create the user
    @user = new_user_service.build(form_params.except(:organization_ids))

    if @user.organization.nil?
      @user.organization_id = @organization_list.first
      org_list = @organization_list
    else
      org_list = form_params[:organization_ids]
    end

    respond_to do |format|
      if @user.save

        # set organizations
        @user.organizations = Organization.where(id: org_list)

        # Assign the role and privileges
        role_service = get_user_role_service
        role_service.set_roles_and_privileges @user, current_user, role_id, privilege_ids
        role_service.post_process @user

        # Perform an post-creation tasks such as sending emails, etc.
        new_user_service.post_process @user

        notify_user(:notice, "User #{@user.name} was successfully created.")
        format.html { redirect_to user_url(@user) }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'

    # Get the role_ids and privelege ids and remove them from the params hash
    # as we dont want these managed by the rails associations
    role_id = params[:user][:role_ids]
    privilege_ids = params[:user][:privilege_ids]
    Rails.logger.debug "role_id = #{role_id}, privilege_ids = #{privilege_ids}"

    respond_to do |format|
      if @user.update_attributes(form_params)

        #-----------------------------------------------------------------------
        # Assign the role and privileges but only on a profile form, not a
        # settings form
        #-----------------------------------------------------------------------
        unless role_id.blank?
          role_service = get_user_role_service
          role_service.set_roles_and_privileges @user, current_user, role_id, privilege_ids
          role_service.post_process @user
        end

        new_user_service = get_new_user_service
        # Perform an post-creation tasks such as sending emails, etc.
        new_user_service.post_process @user, true
        
        if @user.id == current_user.id
          notify_user(:notice, "Your profile was successfully updated.")
        else
          notify_user(:notice, "#{@user.name}'s profile was successfully updated.")
        end
        format.html { redirect_to user_url(@user) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end

    end
  end

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def update_password

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Change Password'

    respond_to do |format|
      if @user.update_with_password(form_params)
        # automatically sign in the user bypassing validation
        if @user.id == current_user.id
          notify_user(:notice, "Your password was successfully updated.")
        else
          notify_user(:notice, "#{@user.name}'s password was successfully updated.")
        end
        sign_in @user, :bypass => true
        format.html { redirect_to user_url(@user) }
        format.json { head :no_content }
      else
        format.html { render :action => "change_password" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end


  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def destroy
    if @user.active
      @user.active = false
      @user.notify_via_email = false
      activation = "deactivated"
    else
      @user.active = true
      @user.notify_via_email = true
      activation = "reactivated"
    end
    @user.save(:validate => false)
    respond_to do |format|
      notify_user(:notice, "User #{@user} has been #{activation}.")
      format.html { redirect_to user_url(@user) }
      format.json { head :no_content }
    end
  end

  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def profile_photo
    add_user_breadcrumb('Profile')
    add_breadcrumb 'Profile Photo'
  end

  def popup
    @user = User.find_by_object_key(params[:id])
  end

  def table_preferences
    table_code = params[:table_code] || nil
    render status: 200, json: current_user.table_preferences(table_code)
  end 

  def update_table_preferences
    table_code = table_preference_params[:table_code]
    sort_params = table_preference_params[:sort]
    sorted_columns = sort_params.map{ |sp| {column: sp["column"], order: sp["order"]} }
    table_prefs = eval(current_user.table_preferences || "{}")
    sort_params = {sort: sorted_columns}
    table_prefs[table_code.to_sym] = sort_params
    current_user.update(table_prefs: table_prefs)
    render status: 200, json: current_user.table_preferences(table_code)
  end 

  #------------------------------------------------------------------------------
  # Protected Methods
  #------------------------------------------------------------------------------
  protected

  def set_viewable_organizations
    if current_user.has_role? :admin
      @viewable_organizations = Organization.ids
    else
      @viewable_organizations = current_user.viewable_organizations.select{|org| can?(:authorize, org)}.map(&:id)
    end

    get_organization_selections
  end


  #------------------------------------------------------------------------------
  # Private Methods
  #------------------------------------------------------------------------------
  private

  #-----------------------------------------------------------------------------
  # Never trust parameters from the scary internet, only allow the white list through.
  #-----------------------------------------------------------------------------
  def form_params
    # Remove role and privilege ids as these are managed by the app not by
    # the active record associations
    params[:user].delete :role_ids
    params[:user].delete :privilege_ids
    params.require(:user).permit(user_allowable_params)
  end

  def table_params
    params.permit(:page, :page_size, :search)
  end

  def table_preference_params
    params.permit(:table_code, sort: [:column, :order])
  end

  #-----------------------------------------------------------------------------
  # Callbacks to share common setup or constraints between actions.
  #-----------------------------------------------------------------------------
  def set_user

    if params[:id] == current_user.object_key
      @user = User.find_by(:object_key => params[:id])
    elsif FILTERS_IGNORED
      @user = User.unscoped.find_by(:object_key => params[:id])

      if @user.nil?
        redirect_to '/404'
      end
    else
      @user = User.unscoped.find_by(:object_key => params[:id], :organization_id => @organization_list)

      if @user.nil?
        if User.find_by(:object_key => params[:id], :organization_id => current_user.user_organization_filters.system_filters.first.get_organizations.map{|x| x.id}).nil?
          redirect_to '/404'
        else
          notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
          redirect_to users_path
        end
      end

    end

    return
  end



  #-----------------------------------------------------------------------------
  def add_user_breadcrumb(page)
    if @user.id == current_user.id
      add_breadcrumb "My #{page}", user_path(@user)
    else
      add_breadcrumb @user.name, user_path(@user)
    end
  end

  #-----------------------------------------------------------------------------
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_url(current_user)
    end
  end

  #-----------------------------------------------------------------------------
  # Get the configured service to handle user creation, defaulting
  #-----------------------------------------------------------------------------
  def get_new_user_service
    Rails.application.config.new_user_service.constantize.new
  end

  #-----------------------------------------------------------------------------
  # Get the configured service to handle user role management, defaulting
  #-----------------------------------------------------------------------------
  def get_user_role_service
    Rails.application.config.user_role_service.constantize.new
  end
end
