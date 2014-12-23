class DashboardsController < OrganizationAwareController
 
   add_breadcrumb "Home", :root_path
       
  def index
  	if params["search_text"]
  		client = Swiftype::Client.new
		@dashboard_search_results = client.search("engine", params["search_text"])
	end
  end

end
