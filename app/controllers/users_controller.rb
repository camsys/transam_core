class UsersController < OrganizationAwareController

  #-----------------------------------------------------------------------------
  # Protect controller methods using the cancan ability
  #-----------------------------------------------------------------------------
  authorize_resource :user, except: :popup

  #-----------------------------------------------------------------------------
  add_breadcrumb "Home",  :root_path
  add_breadcrumb "Users", :users_path

  #-----------------------------------------------------------------------------
  before_action :set_user, :only => [:show, :edit, :settings, :update, :destroy, :change_password, :update_password, :profile_photo, :reset_password, :authorizations]
  before_filter :check_for_cancel, :only => [:create, :update, :update_password]
  before_action :check_filter,     :only => [:authorizations]

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
    @role = params[:role]
    @id_filter_list = params[:ids]

    # Start to set up the query
    conditions  = []
    values      = []

    conditions << 'organization_id IN (?)'
    values << @organization_list

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

        query_str << field
        query_str << ' LIKE ? '
        # add the value in for this sub clause
        values << search_value
      end
      query_str << ')' unless searchable_fields.empty?

      conditions << [query_str.join]
    end

    unless @id_filter_list.blank?
      conditions << 'object_key in (?)'
      values << @id_filter_list
    end

    if params[:show_active_only].nil?
      @show_active_only = '1'
    else
      @show_active_only = params[:show_active_only]
    end

    if @show_active_only == '1'
      conditions << 'users.active = ?'
      values << true
    end

    # Get the Users but check to see if a role was selected
    if @role.blank?
      @users = User.where(conditions.join(' AND '), *values).order(:organization_id, :last_name)
    else
      @users = User.with_role(@role).where(conditions.join(' AND '), *values).order(:organization_id, :last_name)
    end

    # Set the breadcrumbs
    if @organization_list.count == 1
      org = Organization.find(@organization_list.first)
      add_breadcrumb org.short_name, users_path(:organization_id => org.id)
    end
    if @role.present?
      add_breadcrumb @role.titleize, users_path(:role => @role)
    end

    # cache the set of object keys in case we need them later
    cache_list(@users, INDEX_KEY_LIST_VAR)

    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
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
      org_list = form_params[:organization_ids].split(',')
    end

    respond_to do |format|
      if @user.save

        # set organizations
        @user.organizations = Organization.where(id: org_list)

        # Perform an post-creation tasks such as sending emails, etc.
        new_user_service.post_process @user

        # Assign the role and privileges
        role_service = get_user_role_service
        role_service.set_roles_and_privileges @user, current_user, role_id, privilege_ids
        role_service.post_process @user

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
      if @user.update_attributes(form_params.except(:organization_ids))


        # Add the (possibly) new organizations into the object
        if form_params[:organization_ids].present?
          org_list = form_params[:organization_ids].split(',')
          @user.organizations = Organization.where(id: org_list)
        end

        # update filters
        # set all filters to personal not shared one
        # then run method that checks your main org and org list to get all shared filters
        unless FILTERS_IGNORED
          @user.update_user_organization_filters
        end

        #-----------------------------------------------------------------------
        # Assign the role and privileges but only on a profile form, not a
        # settings form
        #-----------------------------------------------------------------------
        unless role_id.blank?
          role_service = get_user_role_service
          role_service.set_roles_and_privileges @user, current_user, role_id, privilege_ids
          role_service.post_process @user
        end
        
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
    else
      @user.active = true
    end
    @user.save(:validate => false)
    respond_to do |format|
      notify_user(:notice, "User #{@user} has been deactivated.")
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

  #------------------------------------------------------------------------------
  # Protected Methods
  #------------------------------------------------------------------------------
  protected


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

  #-----------------------------------------------------------------------------
  # Callbacks to share common setup or constraints between actions.
  #-----------------------------------------------------------------------------
  def set_user

    if params[:id] == current_user.object_key
      @user = User.find_by(:object_key => params[:id])
    elsif FILTERS_IGNORED
      @user = User.find_by(:object_key => params[:id])

      if @user.nil?
        redirect_to '/404'
      end
    else
      @user = User.find_by(:object_key => params[:id], :organization_id => @organization_list)

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
