class UsersController < OrganizationAwareController

  before_action :set_user, :only => [:show, :edit, :update, :destroy, :set_current_org, :change_password, :update_password]  
  before_filter :check_for_cancel, :only => [:create, :update, :update_password]
  
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

    # See if we got a org param. If se we are searching within one of the organizations in our list
    # otherwise we are searching our own organization
    if params[:org].blank?
      org = @organization
    else
      org = Organization.find_by_short_name(params[:org])
    end    
    @page_title = "#{org.name}: Users"
    
    if ! params[:search_text].blank?
      @search_text = params[:search_text].strip
      @users = User.search_query(org, @search_text).order(:last_name)           
    else
      @users = org.users.order(:last_name)
    end
    
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
      @page_title = "My Settings"
    else
      @page_title = "#{@user.name}: Settings"
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new

    @page_title = "#{@organization.name}: New User"

    @user = User.new
    @user.organization = @organization

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit

    if @user.id == current_user.id
      @page_title = "My Settings: Update"
    else
      @page_title = "#{@user.name}: Update"
    end

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

  end

  # GET /users/1/edit
  def change_password

    @page_title = "Change Password"
    
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

  end

  # POST /users
  # POST /users.json
  def create

    @user = User.new(form_params)
    @user.organization = @organization

    respond_to do |format|
      if @user.save
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

    if @user.id == current_user.id
      @page_title = "My Settings: Update"
    else
      @page_title = "#{@user.name}: Update"
    end

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    respond_to do |format|
      if @user.update_attributes(form_params)
        notify_user(:notice, "User #{@user.name} was successfully updated.")
        format.html { redirect_to user_url(@user) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update_password

    @page_title = "Change Password"

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      notify_user(:alert, "Record not found!")
      redirect_to users_url
      return
    end

    respond_to do |format|
      if @user.update_with_password(form_params)
        # automatically sign in the user bypassing validation
        notify_user(:notice, "User #{@user.name} was successfully updated.")
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
  
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    allowable_params = user_allowable_params
    allowable_params << :password
    allowable_params << :password_confirmation
    allowable_params << :current_password
    params.require(:user).permit(allowable_params)
  end
  
  # Callbacks to share common setup or constraints between actions.
  def set_user
    @user = params[:id].nil? ? nil : User.find_by_object_key(params[:id])
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to user_url(current_user)
    end
  end
end
