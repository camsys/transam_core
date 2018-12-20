class SavedQueriesController < OrganizationAwareController

  before_action :set_saved_query, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path

  # TODO: Lock down the controller
  # authorize_resource

  # GET /saved_queries
  # GET /saved_queries.json
  def index
    add_breadcrumb "Query", saved_queries_url
    add_breadcrumb "Saved Queries"

    @queries = current_user.saved_queries

    respond_to do |format|
      format.html
      format.json { render :json => @queries }
    end

  end

  # GET /saved_queries/1
  # GET /saved_queries/1.json
  def show

    respond_to do |format|
      format.html 
      format.json
    end

  end

  # GET /saved_queries/new
  def new
    add_breadcrumb "Query", saved_queries_url
    add_breadcrumb "New Query"

    @query = SavedQuery.new
    @query.organization_list = @organization_list
  end

  # GET /saved_queries/1/edit
  def edit

  end

  # POST /saved_queries
  # POST /saved_queries.json
  def create

    @query = SavedQuery.new(saved_query_params)
    @query.organization_list = @organization_list
    @query.created_by_user = current_user

    respond_to do |format|
      if @query.save
        notify_user :notice, 'query was successfully saved.'
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render :show, status: :created, location: @query }
      else
        notify_user :alert, "Cannot save this query because: " + @query.errors.full_messages.join(';')
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saved_queries/1
  # PATCH/PUT /saved_queries/1.json
  def update
    @query.updated_by_user = current_user
    respond_to do |format|
      if @query.update(saved_query_params)
        notify_user :notice, 'Query was successfully updated.'
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render :show, status: :ok, location: @query }
      else
        notify_user :alert, "Cannot update this query because: " + @query.errors.full_messages.join(';')
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /saved_queries/1
  # DELETE /saved_queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      notify_user :notice, 'Query was successfully removed.'
      format.html { redirect_to saved_queries_url }
      format.json { head :no_content }
    end
  end

  # POST /saved_queries/1/query
  def query
    @query = SavedQuery.new
    @query.organization_list = @organization_list
    @query.parse_query_fields saved_query_params[:query_field_ids], saved_query_params[:query_filters]
    
    data_count = @query.data.size
    render json: { count: data_count }
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saved_query
      @query = SavedQuery.find_by(:object_key => params[:id])
      @query.organization_list = @organization_list
      if @query.nil?
        redirect_to '/404'
        return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saved_query_params
      params.require(:saved_query).permit(SavedQuery.allowable_params)
    end
end
