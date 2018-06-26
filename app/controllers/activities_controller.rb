#-------------------------------------------------------------------------------
# ActivitiesController
#
#
#-------------------------------------------------------------------------------
class ActivitiesController < OrganizationAwareController

  before_action :set_activity,          :only =>  [:show, :edit, :update, :destroy]
  before_action :reformat_date_fields,  :only =>  [:create, :update]

  INDEX_KEY_LIST_VAR  = "activities_list_cache_var"
  ACTIVE_FLAG         = '1'
  DASHBOARD_FLAG      = '2'
  SYSTEM_FLAG         = '3'

  ACTIVITY_FLAGS = [
    ["Active", ACTIVE_FLAG],
    ["Show in Dashboard", DASHBOARD_FLAG],
    ["System", SYSTEM_FLAG]
  ]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Activities", :activities_path

  # Lock down the controller
  authorize_resource

  #-----------------------------------------------------------------------------
  # GET /activities
  # GET /activities.json
  #-----------------------------------------------------------------------------
  def index

    # Start to set up the query
    conditions  = []
    values      = []

    @activity_flag_filter = params[:activity_flag_filter]
    if @activity_flag_filter.blank?
      @activity_flag_filter = []
    else
      if @activity_flag_filter.include? ACTIVE_FLAG
        conditions << 'active = ?'
        values << true
      end
      if @activity_flag_filter.include? DASHBOARD_FLAG
        conditions << 'show_in_dashboard = ?'
        values << true
      end
      if @activity_flag_filter.include? SYSTEM_FLAG
        conditions << 'system_activity = ?'
        values << true
      end
    end

    # Get the activities
    @activities = Activity.where(conditions.join(' AND '), *values).order("name, created_at DESC")

    # cache the set of object keys in case we need them later
    cache_list(@activities, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.js
      format.html
      format.json { render :json => @activities }
    end

  end

  #-----------------------------------------------------------------------------
  # GET /activities/1
  # GET /activities/1.json
  #-----------------------------------------------------------------------------
  def show

    add_breadcrumb @activity

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@activity, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : activity_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : activity_path(@next_record_key)

  end

  #-----------------------------------------------------------------------------
  # GET /activities/new
  #-----------------------------------------------------------------------------
  def new

    add_breadcrumb "New Activity"

    @activity = Activity.new

  end

  #-----------------------------------------------------------------------------
  # GET /activities/1/edit
  #-----------------------------------------------------------------------------
  def edit

    add_breadcrumb @activity, activity_path(@activity)
    add_breadcrumb "Update"

  end

  #-----------------------------------------------------------------------------
  # POST /activities
  # POST /activities.json
  #-----------------------------------------------------------------------------
  def create

    add_breadcrumb "New Activity"

    @activity = Activity.new(activity_params)

    respond_to do |format|
      if @activity.save
        notify_user :notice, 'Activity was successfully created.'
        format.html { redirect_to @activity }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  #-----------------------------------------------------------------------------
  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  #-----------------------------------------------------------------------------
  def update

    add_breadcrumb @activity, activity_path(@activity)
    add_breadcrumb "Update"

    respond_to do |format|
      if @activity.update(activity_params)
        notify_user :notice, 'Activity was successfully updated.'
        format.html { redirect_to @activity }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  #-----------------------------------------------------------------------------
  # DELETE /activities/1
  # DELETE /activities/1.json
  #-----------------------------------------------------------------------------
  def destroy
    @activity.destroy
    respond_to do |format|
      notify_user :notice, 'Activity was successfully removed.'
      format.html { redirect_to activities_url }
      format.json { head :no_content }
    end
  end

  #-----------------------------------------------------------------------------
  private
  #-----------------------------------------------------------------------------

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find_by(:object_key => params[:id])
    if @activity.nil?
      redirect_to '/404'
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(Activity.allowable_params)
  end

  def reformat_date(date_str)
    form_date = Date.strptime(date_str, '%m/%d/%Y')
    return form_date.strftime('%Y-%m-%d')
  end

  def reformat_date_fields
    params[:activity][:start_date]  = reformat_date(params[:activity][:start_date]) unless params[:activity][:start_date].blank?
    params[:activity][:end_date]    = reformat_date(params[:activity][:end_date]) unless params[:activity][:end_date].blank?
  end

end
