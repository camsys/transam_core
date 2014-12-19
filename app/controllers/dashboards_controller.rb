class DashboardsController < OrganizationAwareController
 
   add_breadcrumb "Home", :root_path
       
  def index
  	if params["search_text"].present?
  		search_text = params["search_text"]
		@searched_assets = Asset.search(search_text).records
		@searched_customers = Customer.search(search_text).records
	end
  end

end
