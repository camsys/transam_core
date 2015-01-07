class TasksController < NestedResourceController

  add_breadcrumb "Home", :root_path

  before_action :set_view_vars, :only => [:index, :filter]
  before_action :set_task, :only => [:show, :edit, :update, :destroy, :fire_workflow_event]
  before_filter :reformat_date_field, :only => [:create, :update]

  # Ajax callback returning a list of tasks as JSON calendar events
  def filter
    filter_start_time = DateTime.parse(params[:start])
    filter_end_time   = DateTime.parse(params[:end])

    # here we build the query one clause at a time based on the input params
    clauses = []
    values = []
    if @select == "0"
      clauses << ['assigned_to_user_id = ?']
      values << current_user.id
    else
      clauses << ['organization_id = ?']
      values << @organization.id
    end

    clauses << ['state IN (?)']
    values << @states

    clauses << ['complete_by BETWEEN ? AND ?']
    values << filter_start_time
    values << filter_end_time

    tasks = Task.where(clauses.join(' AND '), *values).order("complete_by")

    events = []
    tasks.each do |t|
      if t.assigned_to_user.nil?
        task_title = t.subject
      else
        task_title = "(#{t.assigned_to_user.initials}) #{t.subject}"
      end
      events << {
        :id => t.id,
        :title => task_title,
        :allDay => false,
        :start => t.complete_by,
        :url => user_task_path(current_user, t),
        :className => get_state_css_class_name(t.state)
      }
    end

    respond_to do |format|
      format.json { render :json => events }
    end
  end

  def fire_workflow_event

    # Check that this is a valid event name for the state machines
    if @task.class.event_names.include? params[:event]
      event_name = params[:event]
      if @task.fire_state_event(event_name)
        event = WorkflowEvent.new
        event.creator = current_user
        event.accountable = @task
        event.event_type = event_name
        event.save
      else
        notify_user(:alert, "Could not #{event_name.humanize} task #{@task}")
      end
    else
      notify_user(:alert, "#{params[:event_name]} is not a valid event for a #{@task.class.name}")
    end

    redirect_to :back

  end

  def index

    add_breadcrumb "My Tasks", tasks_path

    # Select tasks for this user or ones that are for the agency as a whole
    @tasks = Task.where("organization_id = ? AND state IN (?) AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", @organization.id, @states, current_user.id).order("complete_by")

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

    add_breadcrumb "My Tasks", tasks_path
    add_breadcrumb @task.subject, task_path(@task)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @task }
    end
  end

  def new

    add_breadcrumb "My Tasks", tasks_path
    add_breadcrumb 'New'

    @taskable = find_resource

    @task = Task.new
    @task.user = current_user
    @task.assigned_to = User.find_by_object_key(params[:assigned_to]) unless params[:assigned_to].nil?
    @task.priority_type = PriorityType.default

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @task }
    end
  end

  def edit

    @taskable = find_resource

    # if not found or the object does not belong to the users
    # send them back to index.html.erb

    add_breadcrumb "My Tasks", tasks_path
    add_breadcrumb @task.subject, task_path(@task)
    add_breadcrumb 'Update', edit_task_path(@task)

    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end

  end

  def create

    @taskable = find_resource
    if @taskable.nil?
      @task = Task.new(form_params)
    else
      @task = @taskable.tasks.build(form_params)
    end

    # Simple form doesn't process mapped associations very well
    #@task.assigned_to_user = User.find(params[:task][:assigned_to_user_id]) unless params[:task][:assigned_to_user_id].blank?
    @task.organization = @task.assigned_to_user.organization unless @task.assigned_to_user.nil?
    @task.user = current_user

    add_breadcrumb "My Tasks", tasks_path
    add_breadcrumb 'New'

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

  def update

    @taskable = @task.taskable

    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      notify_user(:alert, "Record not found!")
      redirect_to user_tasks_url
      return
    end

    add_breadcrumb "My Tasks", tasks_path
    add_breadcrumb @task.subject, task_path(@task)
    add_breadcrumb 'Update', edit_task_path(@task)

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

  # Sets the view variables
  #   @state    - the state filter input in the request
  #   @states   - an array of state names based on the @state
  #   @select   - "0" = assigned to the user, "1" = assigned to the organization
  def set_view_vars
    if params[:state].blank? or params[:state] == "all"
      @state = "all"
      @states = Task.active_states
    else
      @state = params[:state]
      @states = [@state]
    end

    if params[:select].blank?
      @select = "0"
    else
      @select = params[:select]
    end
  end

  def get_state_css_class_name(state)
    if state == "new"
      classname = 'alert alert-error'
    elsif state == "started"
      classname = 'alert alert-info'
    elsif state == "complete"
      classname = 'alert alert-success'
    elsif state == "halted"
      classname = 'alert'
    else
      classname = 'btn'
    end
    classname
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Callbacks to share common setup or constraints between actions.
  def set_task
    @task = params[:id].nil? ? nil : Task.find_by(:object_key => params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:task).permit(Task.allowable_params)
  end

  def reformat_date_field
    unless params[:task][:complete_by].blank?
      date_str = params[:task][:complete_by]
      form_date = Date.strptime(date_str, '%m-%d-%Y')
      params[:task][:complete_by] = form_date.strftime('%Y-%m-%d')
    end
  end

end
