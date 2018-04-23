class DashboardsController < OrganizationAwareController
 
   add_breadcrumb "Home", :root_path
       
  def index

    @queues = []

    @queues << {:name => "Tagged Assets", :view => 'assets_queue', :objs => current_user.assets.where(organization_id: @organization_list)}

    respond_to do |format|
      format.html
    end

  end

end
