class DashboardsController < OrganizationAwareController
        
  def index
    
    add_breadcrumb "Home", :root_path    
    
    @page_title = 'My Dashboard'
    
    # Select messages for this user or ones that are for the agency as a whole
    @messages = Message.where("to_user_id = ? AND opened_at IS NULL", current_user.id).order("created_at DESC")

    # Select tasks for this user or ones that are for the agency as a whole

    # Get the task status types to search for
    task_statuses = []
    task_statuses << TaskStatusType.find_by_name('Not Started')
    task_statuses << TaskStatusType.find_by_name('In Progress')
    task_statuses << TaskStatusType.find_by_name('On Hold')
            
    @tasks = Task.where("assigned_to_user_id = ? AND task_status_type_id IN(?)", current_user.id, task_statuses).order("complete_by")
            
  end

end
