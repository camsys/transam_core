class SearchesController < OrganizationAwareController
                
  def create

    # Need to protect the organization id as it is passed a param
    @searcher = AssetSearcher.new(params[:searcher])
    @searcher.user = current_user
    
    # allow override of organization id
    #if params[:searcher][:organization_id].blank?
    #  org = @organization
    #else
    #  org = current_user.organizations.find(params[:searcher][:organization_id])
    #end
    #@searcher.organization_id = org.nil? ? @organization.id : org.id
    
    @page_title = 'Search Results'
    @assets = @searcher.assets
            
    respond_to do |format|
      format.html { render 'new' }
      format.js   { render 'new' }
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
