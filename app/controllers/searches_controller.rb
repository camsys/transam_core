class SearchesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  ASSET_SEARCH_TYPE             = '1'
  CAPITAL_PLAN_SEARCH_TYPE      = '2'
  ORGANIZATION_SEARCH_TYPE      = '3'
  USER_SEARCH_TYPE              = '4'
  FUNDING_SOURCE_SEARCH_TYPE    = '5'
  FUNDING_LINE_ITEM_SEARCH_TYPE = '6'

  # Session Variables
  INDEX_KEY_LIST_VAR        = "search_key_list_cache_var"

  MAX_ROWS_RETURNED = SystemConfig.instance.max_rows_returned

  # Set the view variables form the params @search_type, @searcher_klass
  before_filter :set_view_vars,     :only => [:create, :new]

  def create

    @searcher = @searcher_klass.constantize.new(params[:searcher])
    @searcher.user = current_user
    @data = @searcher.data

    add_breadcrumb "Search"
    add_breadcrumb "Results"

    # Cache the result set so the use can page through them
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
    @searcher.user = current_user
    @data = []

    add_breadcrumb "Search"

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Action for performing full text search using the search text index
  def keyword

    @search_text = params["search_text"] ||= ""

    add_breadcrumb "Keyword Search: '#{@search_text}'"

    if @search_text.blank?
      @keyword_search_results = KeywordSearchIndex.where("1 = 2")
    else

      # here we build the query one clause at a time based on the input params. The query
      # is of the form:
      #
      # where organization_id IN (?) AND (search_text LIKE ? OR search_text_like ? OR ... )

      where_clause = 'organization_id IN (?) AND ('
      values = []
      values << @organization.id

      search_params = []
      @search_text.split(" ").each_with_index do |search_string|
        unless search_string.length < 2
          search_params << 'search_text LIKE ?'
          values << "%#{search_string}%"
        end
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

    @search_type = params[:search_type]
    if @search_type == ASSET_SEARCH_TYPE
      @searcher_klass = "AssetSearcher"
      add_breadcrumb "Assets", inventory_index_path
    elsif @search_type == CAPITAL_PLAN_SEARCH_TYPE
      @searcher_klass = "CapitalProjectSearcher"
      add_breadcrumb "Capital Projects", capital_projects_path
    elsif @search_type == ORGANIZATION_SEARCH_TYPE
      @searcher_klass = "OrganizationSearcher"
      add_breadcrumb "Organizations", organizations_path
    elsif @search_type == USER_SEARCH_TYPE
      @searcher_klass = "UserSearcher"
      add_breadcrumb "Users", users_path
    elsif @search_type == FUNDING_SOURCE_SEARCH_TYPE
      @searcher_klass = "FundingSourceSearcher"
      add_breadcrumb "Funds", funding_sources_path
    elsif @search_type == FUNDING_LINE_ITEM_SEARCH_TYPE
      @searcher_klass = "FundingLineItemSearcher"
      add_breadcrumb "Appropriations", funding_line_items_path
    else
      notify_user(:alert, "Something went wrong. Can't determine type of search to perform.")
      redirect_to root_path
      return
    end

  end

end
