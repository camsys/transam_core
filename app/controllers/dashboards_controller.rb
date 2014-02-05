class DashboardsController < OrganizationAwareController
        
  def index
    
    @page_title = 'Dashboard'
    
    # Select messages for this user or ones that are for the agency as a whole
    @messages = Message.where("organization_id = ? AND to_user_id = ? AND opened_at IS NULL)", @organization.id, current_user.id).order("created_at DESC")
    # Select tasks for this user or ones that are for the agency as a whole
    @tasks = Task.where("for_organization_id = ? AND completed_on IS NULL AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", @organization.id, current_user.id).order("complete_by")
            
  end

end
