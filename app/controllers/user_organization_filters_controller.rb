class UserOrganizationFiltersController < OrganizationAwareController

  add_breadcrumb "Home",  :root_path

  before_action :set_user_organization_filter, :only => [:show, :edit, :update, :destroy]

  # GET /user_organization_filters
  # GET /user_organization_filters.json
  def index

    add_breadcrumb "Organization Filters"

    @user_organization_filters = current_user.user_organization_filters

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

    set_current_user_organization_filter_(current_user, @user_organization_filter)

    redirect_to :back

  end

  def set_org
    @user_organization_filter = UserOrganizationFilter.find_by_object_key(params[:user_organization_filter_id])

    if @user_organization_filter.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to :back
      return
    end

    # Set the session variable to store the org selected
    set_selected_organization_list(Organization.where(id: params[:org_user_organization_filter]))

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

    @user_organization_filter = UserOrganizationFilter.new(form_params.except(:organization_ids))
    @user_organization_filter.creator = current_user
    if params[:share_filter]
      @user_organization_filter.users = current_user.organization.users
      @user_organization_filter.resource = current_user.organization
    else
      @user_organization_filter.users = [current_user]
    end

    # Add the organizations into the object. Make sure that the elements are unique so
    # the same org is not added more than once.
    org_list = form_params[:organization_ids].split(',').uniq
    org_list.each do |id|
      @user_organization_filter.organizations << Organization.find(id)
    end

    respond_to do |format|
      if @user_organization_filter.save

        if params[:commit] == "Update and Select This Filter"
          set_current_user_organization_filter_(current_user, @user_organization_filter)
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



    respond_to do |format|
      if @user_organization_filter.update(form_params)

        # Add the (possibly) new organizations into the object
        org_list = form_params[:organization_ids].split(',')
        if org_list.count > 0
          # clear the existing list of organizations
          @user_organization_filter.organizations.clear
          org_list.each do |id|
            @user_organization_filter.organizations << Organization.find(id)
          end
        end

        if params[:share_filter]
          @user_organization_filter.users = current_user.organization.users
          @user_organization_filter.resource = current_user.organization
        else
          @user_organization_filter.users.clear
          @user_organization_filter.resource = nil
        end


        if params[:commit] == "Update and Select This Filter"
          set_current_user_organization_filter_(current_user, @user_organization_filter)
        end


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
      params.require(:user_organization_filter).permit(UserOrganizationFilter.allowable_params)
    end
end
