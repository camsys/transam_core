class TasksController < OrganizationAwareController
  
  before_action :set_task, :only => [:show, :edit, :update, :destroy, :update_status]  
  before_filter :check_for_cancel, :only => [:create, :update] 

  SESSION_VIEW_TYPE_VAR   = 'tasks_subnav_view_type'
  SESSION_FILTER_TYPE_VAR = 'tasks_subnav_filter_type'
  SESSION_SELECT_TYPE_VAR = 'tasks_subnav_select_type'
  
  # Ajax callback returning a list of tasks as JSON calendar events
  def filter
    filter_start_time = DateTime.strptime(params[:start], '%s')
    filter_end_time   = DateTime.strptime(params[:end], '%s')
    @filter = get_filter_type(SESSION_FILTER_TYPE_VAR)
    @select = get_select_type(SESSION_SELECT_TYPE_VAR)
    
    # here we build the query one clause at a time based on the input params
    clauses = []
    values = []
    if @select == 0
      clauses << ['assigned_to_user_id = ?']
      values << [current_user.id]
    else
      clauses << ['for_organization_id = ?']
      values << [current_user.organization.id]
    end
    if @filter.to_i > 0
      clauses << ['task_status_type_id = ?']
      values << [@filter]      
    end
    clauses << ['complete_by BETWEEN ? AND ?']
    values << [filter_start_time]
    values << [filter_end_time]
    
    tasks = Task.where(clauses.join(' AND '), *values).order("complete_by")

    events = []
    tasks.each do |t|
      events << {
        :id => t.id,
        :title => @select == 0 ? t.subject : "(#{t.assigned_to.initials}) #{t.subject}",
        :allDay => false,
        :start => t.complete_by,
        :url => user_task_path(current_user, t),
        :className => get_css_class_name(t)
      }
    end

    respond_to do |format|
      format.json { render :json => events }
    end
  end
  
  def index

    @page_title = 'My Tasks'
    @filter = get_filter_type(SESSION_FILTER_TYPE_VAR)
    @select = get_select_type(SESSION_SELECT_TYPE_VAR)
    
    # Select tasks for this user or ones that are for the agency as a whole
    @tasks = Task.where("for_organization_id = ? AND completed_on IS NULL AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", @organization.id, current_user.id).order("complete_by")
    
    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @tasks }
    end
  end

  def show

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end
 
    @page_title = 'Task'
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @task }
    end
  end

  def new

    @page_title = 'New Task'

    @task = Task.new
    @task.from_organization = @organization
    @task.from_user = current_user
    @task.complete_by = Date.today + 1
    @task.priority_type = PriorityType.default
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @task }
    end
  end

  def edit

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    @page_title = 'Edit Task'

    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end

  end

  def create

    @task = Task.new(form_params)
    # Simple form doesn't process mapped assoacitions very well
    @task.assigned_to = User.find(params[:task][:assigned_to_user_id]) unless params[:task][:assigned_to_user_id].blank?
    @task.for_organization = @task.assigned_to.organization unless @task.assigned_to.nil?
    
    @task.from_organization = @organization
    @task.from_user = current_user

    respond_to do |format|
      if @task.save
        notify_user(:notice, "Task was successfully created.")
        format.html { redirect_to user_tasks_url(current_user) }
        format.json { render :json => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update_status

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end

    @task.task_status_type = TaskStatusType.find(params[:task_status])
    if @task.task_status_type.name == 'Complete'
      @task.completed_on = Date.today
    else 
      @task.completed_on = nil
    end
    
    respond_to do |format|
      if @task.save
        notify_user(:notice, "Task was successfully updated.")
        format.html { redirect_to user_task_url(current_user, @task) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end

    respond_to do |format|
      if @task.update_attributes(form_params)
        notify_user(:notice, "Task was successfully updated.")
        format.html { redirect_to user_tasks_url(current_user) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
  
  # returns the filter type for the current controller and sets the session variable
  # to store any change in fitler type for the controller
  def get_filter_type(session_var)
    filter_type = params[:filter].nil? ? session[session_var].to_i : params[:filter].to_i
    if filter_type.nil?
      filter_type = 0
    end
    # remember the view type in the session
    session[session_var] = filter_type   
    return filter_type 
  end
  # returns the select type for the current controller and sets the session variable
  # to store any change in select type for the controller
  def get_select_type(session_var)
    select_type = params[:select].nil? ? session[session_var].to_i : params[:select].to_i
    if select_type.nil?
      select_type = 0
    end
    # remember the view type in the session
    session[session_var] = select_type   
    return select_type 
  end
  
  def get_event_color(task)
    if task.task_status_type_id == 1      # New
      color = '#FF0000'
    elsif task.task_status_type_id == 2   # In Progress
      color = '#00FF00'
    elsif task.task_status_type_id == 3   # Complete
      color = '#0000FF'
    elsif task.task_status_type_id == 4   # On Hold
      color = '#00FFFF'
    else
      color = 'FF00FF'                    # Cancelled
    end
    color
  end
  def get_css_class_name(task)
    if task.task_status_type_id == 1      # New
      classname = 'alert alert-error'
    elsif task.task_status_type_id == 2   # In Progress
      classname = 'alert alert-info'
    elsif task.task_status_type_id == 3   # Complete
      classname = 'alert alert-success'
    elsif task.task_status_type_id == 4   # On Hold
      classname = 'alert'
    else
      classname = 'btn'                    # Cancelled
    end
    classname
  end
  
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def check_for_cancel
    unless params[:cancel].blank?
      # check that the user has access to this agency
      redirect_to(user_tasks_url(current_user))
    end
  end 
  
  # Callbacks to share common setup or constraints between actions.
  def set_task
    @task = params[:id].nil? ? nil : Task.find_by_object_key(params[:id])
  end

  # make sure that only tasks for this user or unassigned tasks for this agency are viewed or edited
  def find_task(task_id)
    Task.where("id = ? AND for_organization_id = ? AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", task_id, @organization.id, current_user.id).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:task).permit(task_allowable_params)
  end
  
end
