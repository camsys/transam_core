class TasksController < OrganizationAwareController
  #before_filter :authorize_admin
  before_filter :check_for_cancel, :only => [:create, :update] 

  SESSION_VIEW_TYPE_VAR = 'tasks_subnav_view_type'
  
  def index

    @page_title = 'Tasks'
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

    @task = find_task(params[:id])
    
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      redirect_to(user_tasks_url, :flash => { :alert => 'Record not found!'})
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

    @task = find_task(params[:id])
    
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      redirect_to(user_tasks_url(current_user), :flash => { :alert => 'Record not found!'})
    end

  end

  def create

    @task = Task.new(params[:task])
    # Simple form doesn't process mapped assoacitions very well
    @task.assigned_to = User.find(params[:task][:assigned_to_user_id]) unless params[:task][:assigned_to_user_id].blank?
    @task.for_organization = @task.assigned_to.organization unless @task.assigned_to.nil?
    
    @task.from_organization = @organization
    @task.from_user = current_user

    respond_to do |format|
      if @task.save
        format.html { redirect_to user_tasks_url(current_user), :notice => "Task was successfully created." }
        format.json { render :json => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update

    @task = find_task(params[:id])
    
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @task.nil?
      redirect_to(user_tasks_url(current_user), :flash => { :alert => 'Record not found!'})
      return
    end

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to user_tasks_url(current_user), :notice => "Task was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def check_for_cancel
    unless params[:cancel].blank?
      # check that the user has access to this agency
      redirect_to(user_tasks_url(current_user))
    end
  end 
  
  # make sure that only tasks for this user or unassigned tasks for this agency are viewed or edited
  def find_task(task_id)
    Task.where("id = ? AND for_organization_id = ? AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", task_id, @organization.id, current_user.id).first
  end
end
