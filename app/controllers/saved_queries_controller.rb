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

  # POST /saved_queries/query
  def query
    @query = SavedQuery.new
    @query.organization_list = @organization_list
    @query.parse_query_fields saved_query_params[:query_field_ids], saved_query_params[:query_filters]
    
    data_count = @query.data.size
    render json: { count: data_count }
  end

  # GET /saved_queries/export
  #   Use GET request in order to download file, POST won't work
  #   This also changes param structure, therefore, need to do some customized param parsing
  def export
    @query = SavedQuery.new
    @query.organization_list = @organization_list
    filter_data_array = saved_query_params[:query_filters].to_h.map{|idx,filter_data| filter_data} # a bit dirty, but needed
    @query.parse_query_fields saved_query_params[:query_field_ids], filter_data_array
    respond_to do |format|
      format.html
      format.csv do 
        render_csv("query_results_#{Time.current.strftime('%Y%m%d%H%M')}.csv")
      end
    end
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

    def render_csv(file_name)
      set_file_headers file_name
      set_streaming_headers

      response.status = 200

      #setting the body to an enumerator, rails will iterate this enumerator
      self.response_body = csv_lines
    end


    def set_file_headers(file_name)
      headers["Content-Type"] = "text/csv"
      headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
    end


    def set_streaming_headers
      #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
      headers['X-Accel-Buffering'] = 'no'

      headers["Cache-Control"] ||= "no-cache"
      headers.delete("Content-Length")
    end

    def csv_lines
      field_names = {}
      headers = []
      @query.query_fields.each do |field|
        headers << field.label
        
        field_name = field.name
        as_names = []
        field.query_asset_classes.each do |qac|
          as_names << "#{qac.table_name}_#{field_name}"
        end
        field_names[field_name] = as_names
      end

      # Excel is stupid if the first two characters of a csv file are "ID". Necessary to
      # escape it. https://support.microsoft.com/kb/215591/EN-US
      if headers.any? && headers[0].start_with?("ID")
        headers = Array.new(headers)
        headers[0] = "'" + headers[0]
      end

      Enumerator.new do |y|
        CSV.generate do |csv|
          unless field_names.blank?
            y << headers.to_csv

            # find_each would reduce memory usage, but it relies on valid primary_key
            @query.data.find_each do |row|
              row_data = field_names.map { |field_name, as_names|
                val = nil
                as_names.each do |as_name|
                  if row.send(as_name)
                    val = row.send(as_name)
                    break
                  end 
                end
                val
              }
              
              y << row_data.to_csv
            end

          end
        end
      end

    end
end
