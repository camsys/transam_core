class ActivityLogsController < OrganizationAwareController
    
  def index

    @page_title = 'Activity Log'
   
    # get the policies for this agency 
    @activities = ActivityLog.where(organization: @organization_list).order('activity_time')
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @activities }
    end
  end
  
  
end
