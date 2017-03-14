class SavedSearchesController < OrganizationAwareController

  before_action :set_search, only: [:show, :edit, :update, :destroy, :reorder]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Saved Searches", :saved_searches_path

  # Lock down the controller
  authorize_resource

  # GET /saved_searches
  # GET /saved_searches.json
  def index

    if params[:search_type_id]
      @search_type = SearchType.find_by(id: params[:search_type_id].to_i)
      @searches = current_user.saved_searches.includes(:search_type).where(search_type_id: @search_type.try(:id))
    else
      @searches = current_user.saved_searches.includes(:search_type)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @searches }
    end

  end

  # GET /saved_searches/1
  # GET /saved_searches/1.json
  def show

    # When loading a saved search we want to save the resulting search proxy
    # to the session cache and re-direct to either the map search or work search
    # page

    respond_to do |format|
      format.html {
        search_proxy = @search.search_proxy
        # cache the search proxy
        Rails.logger.debug search_proxy.inspect

        if search_proxy
          search_type = @search.search_type
          searcher = search_type.class_name.constantize.new(search_proxy)
          cache_objects(searcher.cache_params_variable_name, search_proxy)
          cache_list(searcher.data, searcher.cache_variable_name)

          redirect_to new_search_url(search_type: search_type.id), status: 303
        end
      }
      format.js # load SQL in modal
    end

  end

  # GET /saved_searches/new
  def new

    @search = SavedSearch.new
  end

  # GET /saved_searches/1/edit
  def edit

  end

  # POST /saved_searches
  # POST /saved_searches.json
  def create

    @search = SavedSearch.new(saved_search_params)
    @search.ordinal = SavedSearch.where(user: current_user).maximum(:ordinal).to_i + 1 
    @search.user = current_user
    @search.search_type = SearchType.find_by(class_name: 'AssetSearcher')

    # Get the search proxy from the cache
    search_proxy = get_cached_objects(@search.search_type.class_name.constantize.new.cache_params_variable_name)

    # Save the name of the search
    #search_proxy.name = @search.name
    # serialize the search proxy to JSON
    @search.json = search_proxy.to_json
    @search.query_string = @search.search_type.class_name.constantize.new(search_proxy).to_s

    respond_to do |format|
      if @search.save
        notify_user :notice, 'Search was successfully saved.'
        format.html { redirect_to :back }
        format.json { render :show, status: :created, location: @search }
      else
        notify_user :alert, "Cannot save this search because: " + @search.errors.full_messages.join(';')
        format.html { redirect_to :back }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saved_searches/1
  # PATCH/PUT /saved_searches/1.json
  def update

    respond_to do |format|
      if @search.update(saved_search_params)
        notify_user :notice, 'Search was successfully updated.'
        format.html { redirect_to :back }
        format.json { render :show, status: :ok, location: @search }
      else
        notify_user :alert, "Cannot update this search because: " + @search.errors.full_messages.join(';')
        format.html { redirect_to :back }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      notify_user :notice, 'Search was successfully removed.'
      format.html { redirect_to saved_searches_url }
      format.json { head :no_content }
    end
  end

  #-----------------------------------------------------------------------------
  # Reorders a search via AJAX. The saved search is identified by the object key.
  #-----------------------------------------------------------------------------
  def reorder
    if params[:move]
      if params[:move].to_i == -1
        is_move_up = true
      elsif params[:move].to_i == 1
        is_move_down = true
      end
    end

    if is_move_up || is_move_down
      exchange_search = SavedSearch.find_by(:object_key => params[:target])
      old_ordinal = @search.ordinal
      if exchange_search
        @search.ordinal = exchange_search.ordinal    
        @search.save(:validate => false)

        exchange_search.ordinal = old_ordinal
        exchange_search.save(:validate => false)
      end
    end

    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = SavedSearch.find_by(:object_key => params[:id])
      if @search.nil?
        redirect_to '/404'
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saved_search_params
      params.require(:saved_search).permit(SavedSearch.allowable_params)
    end
end
