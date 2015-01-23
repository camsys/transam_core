class ActivityLogsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  before_action :set_activity, only: [:show]

  INDEX_KEY_LIST_VAR    = "activity_log_key_list_cache_var"

  def index

    add_breadcrumb "Activity Log"

    # get the policies for this agency
    @activities = ActivityLog.where(organization: @organization_list).order('activity_time')

    # cache the set of object keys in case we need them later
    #cache_list(@activities, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @activities }
    end
  end

  def show
    add_breadcrumb "Activity Log", activity_logs_path
    add_breadcrumb @activity

    # get the @prev_record_path and @next_record_path view vars
    #get_next_and_prev_object_keys(@activity, INDEX_KEY_LIST_VAR)
    #@prev_record_path = @prev_record_key.nil? ? "#" : activity_log_path(@prev_record_key)
    #@next_record_path = @next_record_key.nil? ? "#" : activity_log_path(@next_record_key)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @activity }
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = ActivityLog.find(params[:id]) unless params[:id].nil?
  end

end
