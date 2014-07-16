class UserOrganizationFiltersController < OrganizationAwareController
  
  add_breadcrumb "Home",  :root_path
  
  before_action :set_user_organization_filter, :only => [:show, :edit, :update, :destroy]

  # GET /user_organization_filters
  # GET /user_organization_filters.json
  def index

    add_breadcrumb "Organization Filters"

    @system_filters = UserOrganizationFilter.system_filters
    @user_organization_filters = current_user.organization_filters
  end

  # GET /user_organization_filters/1
  # GET /user_organization_filters/1.json
  def show
    
    if @user_organization_filter.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to :back
      return
    end
    
    add_breadcrumb "Organization Filters", user_user_organization_filters_path(current_user)
    add_breadcrumb @user_organization_filter.name

  end

  #
  def use
    # Set the user's organization list for reporting and filtering to the list defined by
    # the selected filter

    @user_organization_filter = UserOrganizationFilter.find_by_object_key(params[:user_organization_filter_id])

    if @user_organization_filter.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to :back
      return
    end
    
    Rails.logger.debug "Setting agency filter to: #{@user_organization_filter.grantees.inspect}"
    
    # Set the session variable to store the list of organizations for reporting
    set_selected_organization_list(@user_organization_filter.grantees)

    # Save the selection. Next time the user logs in the filter will be reset
    current_user.user_organization_filter = @user_organization_filter
    current_user.save

    notify_user(:notice, "Using agency filter #{@user_organization_filter.name}")
    # Set the filter name in the session
    session[:user_organization_filter] = @user_organization_filter.name
    
    redirect_to :back
    
  end

  # GET /user_organization_filters/new
  def new

    add_breadcrumb "Organization Filters", user_user_organization_filters_path(current_user)
    add_breadcrumb "New"
    
    @user_organization_filter = UserOrganizationFilter.new
  end

  # GET /user_organization_filters/1/edit
  def edit

    if @user_organization_filter.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to :back
      return
    end
    
    add_breadcrumb "Organization Filters", user_user_organization_filters_path(current_user)
    add_breadcrumb @user_organization_filter.name, user_user_organization_filter_path(current_user, @user_organization_filter)
    add_breadcrumb "Update"


  end

  # POST /user_organization_filters
  # POST /user_organization_filters.json
  def create

    add_breadcrumb "Organization Filters", user_user_organization_filters_path(current_user)
    add_breadcrumb "New"

    @user_organization_filter = UserOrganizationFilter.new(form_params.except(:grantee_ids))
    @user_organization_filter.user = current_user

    respond_to do |format|
      if @user_organization_filter.save
        # Add the grantees into the object. Make sure that the elements are unique so
        # the same org is not added more than once.
        grantee_list = form_params[:grantee_ids].split(',').uniq
        grantee_list.each do |id|
          @user_organization_filter.grantees << Grantee.find(id)
        end
        
        notify_user(:notice, 'Filter was sucessfully created.')
        format.html { redirect_to [current_user, @user_organization_filter] }
        format.json { render action: 'show', status: :created, location: @user_organization_filter }
      else
        format.html { render action: 'new' }
        format.json { render json: @user_organization_filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_organization_filters/1
  # PATCH/PUT /user_organization_filters/1.json
  def update

    if @user_organization_filter.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to :back
    end

    add_breadcrumb "Organization Filters", user_user_organization_filters_path(current_user)
    add_breadcrumb @user_organization_filter.name, user_user_organization_filter_path(current_user, @user_organization_filter)
    add_breadcrumb "Update"

    respond_to do |format|
      if @user_organization_filter.update(form_params)
        # clear the existing list of grantees
        @user_organization_filter.grantees.clear
        # Add the (possibly) new grantees into the object
        grantee_list = form_params[:grantee_ids].split(',')
        grantee_list.each do |id|
          @user_organization_filter.grantees << Grantee.find(id)
        end
        
        
        puts @user_organization_filter.inspect
        notify_user(:notice, 'Filter was sucessfully updated.')
        format.html { redirect_to [current_user, @user_organization_filter] }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_organization_filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_organization_filters/1
  # DELETE /user_organization_filters/1.json
  def destroy
    @user_organization_filter.destroy
    notify_user(:notice, 'Filter was sucessfully removed.')
    respond_to do |format|
      format.html { redirect_to user_user_organization_filters_path(current_user) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_organization_filter
      @user_organization_filter = UserOrganizationFilter.find_by_object_key(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def form_params
      params.require(:user_organization_filter).permit(user_organization_filter_allowable_params)
    end
end
