class UsersController < OrganizationAwareController

  # Protect controller methods using the cancan ability
  authorize_resource

  add_breadcrumb "Home",  :root_path
  add_breadcrumb "Users", :users_path

  before_action :set_user, :only => [:show, :edit, :settings, :update, :destroy, :set_current_org, :change_password, :update_password, :profile_photo, :reset_password]
  before_filter :check_for_cancel, :only => [:create, :update, :update_password]

  INDEX_KEY_LIST_VAR    = "user_key_list_cache_var"
  SESSION_VIEW_TYPE_VAR = 'users_subnav_view_type'

  # User has selected an alternative org to view. This method sets a session variable
  # which is used by OrganizationAwareController to set the @organization variable
  # for subsequent views.
  def set_current_org
    org = @user.organizations.find_by_short_name(params[:orgs][:org_id])
    if org.nil?
      notify_user(:alert, "Record not found!")
      redirect_to :back
      return
    end
    # Set the user's selected org
    set_selected_organization(org)

    notify_user(:notice, "You are now viewing #{org.name}")
    # send the user back to the view they were looking at. This might
    # cause another redirect if the view is not associated with the
    # newly selected organization
    redirect_to :back

  end
  # GET /users
  # GET /users.json
  def index

    # Start to set up the query
    conditions  = []
    values      = []

    # See if we got an organization id
    @organization_id = params[:organization_id]
    if @organization_id.present?
      @organization_id = @organization_id.to_i
      conditions << 'organization_id = ?'
      values << @organization_id
    else
      conditions << 'organization_id IN (?)'
      values << @organization_list
    end

    # Get the Users but check to see if a role was selected
    @role = params[:role]
    if @role.blank?
      @users = User.where(conditions.join(' AND '), *values).order(:organization_id, :last_name)
    else
      @users = User.with_role(@role).where(conditions.join(' AND '), *values).order(:organization_id, :last_name)
    end

    # Set the breadcrumbs
    if @organization_id.present?
      org = Organization.find(@organization_id)
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

  # GET /users/1
  # GET /users/1.json
  def show

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

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

  # GET /users/new
  # GET /users/new.json
  def new

    add_breadcrumb 'New'

    @user = User.new
    @user.organization = @organization

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'

  end

  # Sends a reset password email to the user. This is an admin function
  def reset_password

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    @user.send_reset_password_instructions
    notify_user(:notice, "Instructions for resetting their password was sent to #{@user} at #{@user.email}")

    redirect_to user_path(@user)

  end

  # GET /users/1/edit
  def change_password

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Change Password'

  end

  def settings

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'
  end

  # POST /users
  # POST /users.json
  def create

    # Get a new user service to invoke any business logic associated with creating
    # new users
    new_user_service = get_new_user_service
    # Create the user
    @user = new_user_service.build(form_params)
    @user.organization = @organization unless @user.organization # allow for mass-assignment of organization

    add_breadcrumb 'New'

    respond_to do |format|
      if @user.save
        # Perform an post-creation tasks such as sending emails, etc.
        new_user_service.post_process(@user)
        notify_user(:notice, "User #{@user.name} was successfully created.")
        format.html { redirect_to user_url(@user) }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Update'

    respond_to do |format|
      if @user.update_attributes(form_params)
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

  def update_password

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    add_user_breadcrumb('Profile')
    add_breadcrumb 'Change Password'

    respond_to do |format|
      if @user.update_with_password(params.required(:user).permit(:current_password, :password, :password_confirmation))
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


  def destroy

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    @user.destroy
    notify_user(:notice, "User was successfully removed.")

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def profile_photo
    add_user_breadcrumb('Profile')
    add_breadcrumb 'Profile Photo'
  end
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:user).permit(User.allowable_params)
  end

  # Callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by_object_key(params[:id])
  end

  def add_user_breadcrumb(page)
    if @user.id == current_user.id
      add_breadcrumb "My #{page}", user_path(@user)
    else
      add_breadcrumb @user.name, user_path(@user)
    end
  end

  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_url(current_user)
    end
  end

  # Get the configured service to handle user creation, defaulting
  def get_new_user_service
    if Rails.application.config.new_user_service
      Rails.application.config.new_user_service.constantize.new
    else
      NewUserService.new
    end
  end
end
