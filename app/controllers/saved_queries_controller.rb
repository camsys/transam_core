class SavedQueriesController < OrganizationAwareController

  before_action :set_saved_query, only: [:show, :update, :destroy, :export, :clone, :remove_from_orgs, :show_remove_form]

  add_breadcrumb "Home", :root_path

  # Lock down the controller
  authorize_resource

  # GET /saved_queries
  # GET /saved_queries.json
  def index
    add_breadcrumb "Query", saved_queries_url
    add_breadcrumb "Saved Queries"

    # list own queries, plus shared from other orgs
    own_querie_ids = current_user.saved_queries.pluck(:id)
    shared_querie_ids = SavedQuery.joins(:organizations).where("organizations.id": current_user.organization_ids).pluck("saved_queries.id").uniq

    @queries = SavedQuery.where(id: (own_querie_ids + shared_querie_ids).uniq).uniq

    respond_to do |format|
      format.html
      format.json { render :json => @queries }
    end

  end

  # GET /saved_queries/1
  # GET /saved_queries/1.json
  def show
    add_breadcrumb "Query", saved_queries_url
    add_breadcrumb @query.name

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
    @query.created_by_user = current_user
    @query.organization_list = @organization_list
  end

  def save_as
    if params[:id].blank?
      @query = SavedQuery.new
      @query.created_by_user = current_user
    else
      @query = SavedQuery.find_by_object_key(params[:id])
    end
  end

  # GET /saved_queries/1/clone
  def clone
    cloned_query = @query.clone!
    cloned_query.organization_list = @organization_list
    cloned_query.created_by_user = current_user

    respond_to do |format|
      if cloned_query.save
        notify_user :notice, 'Query was successfully cloned.'
        format.html { redirect_to saved_query_path(cloned_query) }
        format.json { render :show, status: :created, location: cloned_query }
      else
        notify_user :alert, "Cannot clone this query because: " + cloned_query.errors.full_messages.join(';')
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render json: cloned_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # This is to remove a shared query from other org
  def remove_from_orgs
    if params[:saved_query] && !params[:saved_query][:organization_ids].blank?
      # exclude query main org (where it's created)
      to_remove_org_ids = params[:saved_query][:organization_ids].select{|r| !r.blank? && r != @query.created_by_user.try(:organization_id).to_s}

      @query.organizations.delete(*to_remove_org_ids) if to_remove_org_ids.any?
    end

    redirect_to saved_queries_path
  end

  def show_remove_form
    @to_remove_org_ids = (@query.organization_ids || []) & (current_user.organization_ids || []) - [@query.created_by_user.try(:organization_id)]
    @to_remove_orgs = Organization.where(id: @to_remove_org_ids)
  end

  # POST /saved_queries
  # POST /saved_queries.json
  def create
    @query = SavedQuery.new(saved_query_params.except(:query_field_ids, :query_filters))
    @query.organization_list = @organization_list
    @query.created_by_user = current_user
    filter_data = saved_query_params[:query_filters] ? saved_query_params[:query_filters].to_unsafe_h.map{|r,v| v} : []
    @query.parse_query_fields saved_query_params[:query_field_ids], filter_data
    
    respond_to do |format|
      if @query.save
        notify_user :notice, 'Query was successfully saved.'
        format.html { redirect_to saved_query_path(@query) }
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
    @query.assign_attributes saved_query_params.except(:query_field_ids, :query_filters)
    @query.updated_by_user = current_user
    @query.organization_list = @organization_list
    filter_data = saved_query_params[:query_filters] ? saved_query_params[:query_filters].to_unsafe_h.map{|r,v| v} : []
    @query.parse_query_fields saved_query_params[:query_field_ids], filter_data
    respond_to do |format|
      if @query.save

        notify_user :notice, 'Query was successfully updated.'
        format.html { redirect_to saved_query_path(@query) }
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

  # GET /saved_queries/export_unsaved
  #   Use GET request in order to download file, POST won't work
  #   This also changes param structure, therefore, need to do some customized param parsing
  def export_unsaved
    @query = SavedQuery.new
    @query.organization_list = @organization_list

    # a bit dirty, but needed
    filter_data = saved_query_params[:query_filters].to_h.map{|idx,filter_data| filter_data} unless saved_query_params[:query_filters].blank?
    @query.parse_query_fields saved_query_params[:query_field_ids], filter_data
    respond_to do |format|
      format.html
      format.csv do 
        render_csv("query_results_#{Time.current.strftime('%Y%m%d%H%M')}.csv")
      end
    end
  end

  def export
    @query.organization_list = @organization_list
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
      field_types = {}
      headers = []
      @query.ordered_query_fields.each do |field|
        headers << field.label
        
        field_name = field.name
        field_types[field_name] = field.filter_type

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

                # For readability, show yes/no instead of 1/0.
                if field_types[field_name] == 'boolean'
                  val = (val == 1 ? 'Yes' : 'No')
                end

                # For readability, print in local timezone and convert to AM/PM
                if field_types[field_name] == 'date' and val.is_a? Time
                  val = val.in_time_zone.strftime('%m/%d/%Y %I:%M%p')
                end

                # special case
                if field_name == 'replacement_status_type_id' && val.blank?
                  val = 'By Policy'
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
