class SearchesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  # Session Variables
  INDEX_KEY_LIST_VAR        = "search_key_list_cache_var"

  MAX_ROWS_RETURNED = SystemConfig.instance.max_rows_returned

  # Set the view variables form the params @search_type, @searcher_klass
  before_filter :set_view_vars,     :only => [:create, :new, :reset]

  def create
    # Cache the search params result set so the use can page through them
    unless @searcher.cache_params_variable_name.blank?
      cache_objects(@searcher.cache_params_variable_name, params[:searcher])
    end

    # use organization list if query is for any organization
    params[:searcher][:organization_id] = @organization_list

    @searcher = @searcher_klass.constantize.new(params[:searcher])
    @searcher.user = current_user
    @data = @searcher.data

    unless @searcher.cache_variable_name.blank?
      cache_list(@data, @searcher.cache_variable_name)
    end

    respond_to do |format|
      format.html { render 'new' }
      format.js   { render 'new' }
      format.json { render :json => @data }
    end

  end

  # Render the inventory search form
  def new

    @searcher = @searcher_klass.constantize.new
    unless @searcher.cache_params_variable_name.blank?
      cached_search_params = get_cached_objects(@searcher.cache_params_variable_name)
      @searcher = @searcher_klass.constantize.new(cached_search_params) unless cached_search_params.blank?
    end
    @searcher.user = current_user

    cached_list = get_cached_objects(@searcher.cache_variable_name)
    if cached_list.blank?
      @data = []
    else
      @data = @searcher.cached_data(cached_list)
    end

    # check that an order param was provided otherwise use asset_tag as the default
    params[:sort] ||= @searcher.default_sort

    respond_to do |format|
      format.html # new.html.haml this had been an erb and is now an haml the change should just be caught
      format.json {
        render :json => {
            :total => @data.count,
            :rows =>  @data.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset]).as_json(user: current_user, include_early_disposition: false)
        }
      }
    end
  end

  def reset
    @searcher = @searcher_klass.constantize.new

    clear_cached_objects(@searcher.cache_params_variable_name)
    cache_list([], @searcher.cache_variable_name)

    redirect_to new_search_path(:search_type => @search_type.id)
  end

  # Action for performing full text search using the search text index
  def keyword

    @search_text = params["search_text"] ||= ""

    add_breadcrumb "Keyword Search: '#{@search_text}'"

    if @search_text.blank? or @search_text.length < 2
      @keyword_search_results = KeywordSearchIndex.where("1 = 2")
    else

      # here we build the query one clause at a time based on the input params. The query
      # is of the form:
      #
      # where organization_id IN (?) AND (search_text LIKE ? OR search_text_like ? OR ... )

      where_clause = 'organization_id IN (?) AND ('
      values = []
      # The organization is scoped to search across all objects that are owned by
      # the user's list of organizations
      orgs = @organization_list.dup
      # add org = 0 to get objects that are not indexed by org and are by
      # contract available to users of all organizations
      orgs << 0
      values << orgs

      search_params = []
      @search_text.split(",").each_with_index do |search_string|
        search_params << 'search_text LIKE ?'
        values << "%#{search_string.strip}%"
      end

      where_clause << search_params.join(' OR ')
      where_clause << ')'

      @keyword_search_results = KeywordSearchIndex.where(where_clause, *values)

    end

    @num_rows = @keyword_search_results.count
    cache_list(@keyword_search_results, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html
      format.json {
        render :json => {
          :total => @num_rows,
          :rows => data
          }
        }
    end

  end

  protected

  def data
    res = []
    @keyword_search_results.limit(params[:limit]).offset(params[:offset]).each do |row|
      res << {
        'content' => render_to_string(:partial => 'keyword_search_result_detail', :locals => {:search_result => row}).html_safe
      }
    end
    res
  end

  def set_view_vars

    @search_type = SearchType.find_by(id: params[:search_type])

    if @search_type

      add_breadcrumb "Query", new_search_path(:search_type => @search_type.id)

      @searcher_klass = @search_type.class_name
      add_breadcrumb @search_type.name
    else
      notify_user(:alert, "Something went wrong. Can't determine type of search to perform.")
      return
    end

  end

end
