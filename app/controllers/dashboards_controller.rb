class DashboardsController < OrganizationAwareController
 
   add_breadcrumb "Home", :root_path
       
  # def index 
  	
  # 		search_text = 
  # 		search = Asset.search do
  # 			fulltext "4500"
		# end
		# binding.pry
		#   @searched_assets = Asset.search(search_text).records
		#   binding.pry
		#   x=1
		#   #@searched_customers = Customer.search(search_text).records
  #   end
  # end

  def index
  	if params["search_text"].present?
		@search = Asset.search do
		    fulltext params["search_text"]
		    #with(:published_at).less_than(Time.zone.now)
		    #facet(:publish_month)
		    #with(:publish_month, params[:month]) if params[:month].present?
		end
		@searched_assets = @search.results
		binding.pry
		x = 1
	end
  end

end
