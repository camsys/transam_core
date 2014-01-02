class UsersController < OrganizationAwareController

  before_action :set_user, :only => [:show, :edit, :update, :destroy]  
  before_filter :check_for_cancel, :only => [:create, :update, :change_password]
  
  SESSION_VIEW_TYPE_VAR = 'users_subnav_view_type'
  
  # GET /users
  # GET /users.json
  def index
    
    @page_title = @organization.name
    @page_sub_title = 'Users'
    
    if ! params[:search_text].blank?
      @search_text = params[:search_text].strip
      @users = User.search_query(@organization, @search_text).order(:last_name)           
    else
      @users = @organization.users.order(:last_name)
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
      redirect_to(users_url, :flash => { :alert => 'Record not found!'})
      return
    end
 
    @page_title = @user.name
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new

    @page_title = @organization.name
    @page_sub_title = 'New User'

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
      redirect_to(users_url, :flash => { :alert => 'Record not found!'})
    end

  end

  # POST /users
  # POST /users.json
  def create

    @user = User.new(form_params)
    @user.organization = @organization

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), :notice => "User #{@user.name} was successfully created." }
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
      redirect_to(users_url, :flash => { :alert => 'Record not found!'})
      return
    end

    respond_to do |format|
      if @user.update_attributes(form_params)
        format.html { redirect_to user_url(@user), :notice => "User #{@user.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @user.nil?
      redirect_to(users_url, :flash => { :alert => 'Record not found!'})
      return
    end

    @user.destroy

    respond_to do |format|
        format.html { redirect_to users_url, :notice => "User #{@user.name} was successfully removed." }
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
    params.require(:user).permit(user_allowable_params)
  end
  
  # Callbacks to share common setup or constraints between actions.
  def set_user
    @user = params[:id].nil? ? nil : User.find_by_user_key(params[:id])
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to users_url
    end
  end
end
