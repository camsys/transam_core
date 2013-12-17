class SearchController < OrganizationAwareController
                
  def create

    @searcher = AssetSearcher.new(params[:searcher])
    @searcher.organization_id = @organization.id
    
    @page_title = 'Search Results'
    @assets = @searcher.assets
            
    respond_to do |format|
      format.html { render 'new' }
      format.json { render :json => @assets }
    end
    
  end

  # Render the inventory search form
  def new
    @searcher = AssetSearcher.new
    @page_title = 'Asset Search'
    @assets = []
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @searcher }
    end    
  end
   

end
