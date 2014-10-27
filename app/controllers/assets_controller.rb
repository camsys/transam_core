class AssetsController < AssetAwareController

  add_breadcrumb "Home", :root_path

  # Set the view variabless form the params @asset_type, @asset_subtype, @search_text, @spatial_filter, @view
  before_filter :set_view_vars,     :only => [:index, :map]
  # Don't process cancel buttons
  before_filter :check_for_cancel,  :only => [:create, :update]
  # set the @asset variable before any actions are invoked
  before_filter :get_asset,         :only => [:show, :edit, :copy, :update, :destroy, :add_to_group, :remove_from_group]
  before_filter :reformat_date_field, :only => [:create, :update]

  # From the application config
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name
  MAX_ROWS_RETURNED         = SystemConfig.instance.max_rows_returned

  STRING_TOKENIZER          = '|'

  # Session Variables
  INDEX_KEY_LIST_VAR        = "asset_key_list_cache_var"

  # Adds the asset to the specified group
  def add_to_group
    asset_group = AssetGroup.find_by_object_key(params[:asset_group])
    if asset_group.nil?
      notify_user(:alert, "Can't find the asset group selected.")
    else
      if @asset.asset_groups.exists? asset_group
        notify_user(:alert, "Asset #{@asset.name} is already a member of '#{asset_group}'.")
      else
        @asset.asset_groups << asset_group
        notify_user(:notice, "Asset #{@asset.name} was added to '#{asset_group}'.")
      end
    end

    # Always display the last view
    redirect_to :back
  end
  # Removes the asset from the specified group
  def remove_from_group
    asset_group = AssetGroup.find_by_object_key(params[:asset_group])
    if asset_group.nil?
      notify_user(:alert, "Can't find the asset group selected.")
    else
      if @asset.asset_groups.exists? asset_group
        @asset.asset_groups.delete asset_group
        notify_user(:notice, "Asset #{@asset.name} was removed from '#{asset_group}'.")
      else
        notify_user(:alert, "Asset #{@asset.name} is not a member of '#{asset_group}'.")
      end
    end

    # Always display the last view
    redirect_to :back
  end

  # Sets the spatial filter bounding box
  def spatial_filter

    # Check to see if we got spatial filter. If it is nil then spatial fitlering has been
    # diabled
    @spatial_filter = params[:spatial_filter]
    # store it in the session for later
    session[:spatial_filter] = @spatial_filter

  end

  # Implements a map view which includes spatial filtering
  def map

    @assets = get_assets
    @page_title = "#{@asset_class.underscore.humanize.titleize}".pluralize(2)

    markers = []
    @assets.each do |asset|
      if asset.mappable?
        markers << get_map_marker(asset, asset.object_key, false) # not draggable
      end
    end
    @markers = markers.to_json

    # cache the set of asset ids in case we need them later
    cache_list(@assets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html
      format.js
      format.json { render :json => get_as_json(@assets, @row_count) }
      format.xls
    end

  end

  # renders either a table or map view of a selected list of assets
  #
  # Parameters include asset_type, asset_subtype, id_list, box, or search_text
  #
  def index

    # disable any spatial filters for this view
    @spatial_filter = nil
    @assets = get_assets
    if @asset_group.present?
      asset_group = AssetGroup.find_by_object_key(@asset_group)
      add_breadcrumb asset_group

    elsif @asset_subtype == 0
      add_breadcrumb @asset_class.underscore.humanize.titleize.pluralize(2), inventory_index_path(:asset_type => @asset_type, :asset_subtype => 0)
    else
      subtype = AssetSubtype.find(@asset_subtype)
      add_breadcrumb subtype.asset_type.name.pluralize(2), inventory_index_path(:asset_type => subtype.asset_type, :asset_subtype => 0)
      add_breadcrumb subtype.name, inventory_index_path(:asset_subtype =>subtype)
    end

    # cache the set of asset ids in case we need them later
    cache_list(@assets, INDEX_KEY_LIST_VAR)

    respond_to do |format|
      format.html
      format.js
      format.json { render :json => get_as_json(@assets, @row_count) }
      format.xls
    end
  end

  # makes a copy of an asset and renders it. The new asset is not saved
  # and has any identifying chracteristics identified as CLEANSABLE_FIELDS are nilled
  def copy

    add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    add_breadcrumb "Copy"

    # create a copy of the asset and null out all the fields that are identified as cleansable
    new_asset = @asset.copy(true)

    notify_user(:notice, "Asset #{@asset.name} was successfully copied.")

    @asset = new_asset

    # render the edit view
    respond_to do |format|
      format.html { render :action => "edit" }
      format.json { render :json => @asset }
    end

  end

  def show

    add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)

    # get the @prev_record_path and @next_record_path view vars
    get_next_and_prev_object_keys(@asset, INDEX_KEY_LIST_VAR)
    @prev_record_path = @prev_record_key.nil? ? "#" : inventory_path(@prev_record_key)
    @next_record_path = @next_record_key.nil? ? "#" : inventory_path(@next_record_key)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @asset }
    end

  end

  def edit

    add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    add_breadcrumb "Update master record", edit_inventory_path(@asset)

  end

  def update

    @asset.updator = current_user

    add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path
    add_breadcrumb @asset.name, inventory_path(@asset)
    add_breadcrumb "Modify", edit_inventory_path(@asset)

    respond_to do |format|
      if @asset.update_attributes(form_params)

        # If the asset was successfully updated, schedule update the condition and disposition asynchronously
        Delayed::Job.enqueue AssetUpdateJob.new(@asset.object_key, true), :priority => 0
        # See if this asset has any dependents that use its spatial reference
        if @asset.geometry and @asset.dependents.count > 0
          # schedule an update to the spatial references of the dependent assets
          Delayed::Job.enqueue AssetDependentSpatialReferenceUpdateJob.new(@asset.object_key), :priority => 0
        end
        notify_user(:notice, "Asset #{@asset.name} was successfully updated.")

        format.html { redirect_to inventory_url(@asset) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new_asset

    add_breadcrumb "Add Asset", new_asset_inventory_index_path

    @page_title = 'New Asset'
    # Get the asset types for the filter dropdown
    @asset_types = AssetType.all

  end

  def new

    asset_subtype = AssetSubtype.find(params[:asset_subtype])
    if asset_subtype.nil?
      notify_user(:alert, "Asset subtype '#{params[:asset_subtype]}' not found. Can't create new asset!")
      redirect_to(inventory_index_url )
      return
    end

    @page_title = "New #{asset_subtype.name}"
    add_breadcrumb "#{asset_subtype.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => asset_subtype.asset_type)
    add_breadcrumb "#{asset_subtype.name}", inventory_index_path(:asset_subtype => asset_subtype)
    add_breadcrumb "New", new_inventory_path(asset_subtype)

    # Use the base class to create an asset of the correct type
    @asset = Asset.new_asset(asset_subtype)
    @asset.organization = @organization

    # Force the asset to initialize any internal values such as expected_useful_life from the policy
    @asset.initialize_policy_items @organization.get_policy

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @asset }
    end
  end

  def create

    # Need to determine which type of asset we are creating
    asset_type = AssetType.find(params[:asset][:asset_type_id])
    asset_subtype = asset_type.asset_subtypes.find(params[:asset][:asset_subtype_id])
    # get the class name for this asset event type
    class_name = asset_type.class_name
    klass = Object.const_get class_name
    @asset = klass.new(form_params)
    @asset.asset_type = asset_type
    @asset.asset_subtype = asset_subtype
    @asset.organization = @organization
    @asset.creator = current_user
    @asset.updator = current_user

    #Rails.logger.debug @asset.inspect

    add_breadcrumb "#{asset_type.name}".pluralize(2), inventory_index_path(:asset_type => asset_subtype.asset_type)
    add_breadcrumb "#{asset_subtype.name}", inventory_index_path(:asset_subtype => asset_subtype)
    add_breadcrumb "New", new_inventory_path(asset_subtype)

    respond_to do |format|
      if @asset.save
        # If the asset was successfully saved, schedule update the condition and disposition asynchronously
        Delayed::Job.enqueue AssetUpdateJob.new(@asset.object_key), :priority => 0

        notify_user(:notice, "Asset #{@asset.name} was successfully created.")

        format.html { redirect_to inventory_url(@asset) }
        format.json { render :json => @asset, :status => :created, :location => @asset }
      else
        #Rails.logger.debug @asset.errors.inspect
        format.html { render :action => "new" }
        format.json { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # called when the user wants to delete an asset
  def destroy

    # make sure we can find the asset we are supposed to be removing and that it belongs to us.
    if @asset.nil?
      redirect_to(inventory_url, :flash => { :alert => t(:error_404) })
      return
    end

    # Destroy this asset, call backs to remove each associated object will be made
    @asset.destroy

    notify_user(:notice, "Asset was successfully removed.")

    respond_to do |format|
      format.html { redirect_to(inventory_url) }
      format.json { head :no_content }
    end

  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
  #
  # Sets the view variables. This is used to set up the vars before a call to get_assets
  #   @asset_type
  #   @asset_subtype
  #   @search_text
  #   @id_filter_list
  #   @spatial_filter
  #   @fmt
  #   @view
  #   @asset_class_name
  #   @filter
  #
  def set_view_vars

    # Check to see if we got an asset group to sub select on. This occurs when the user
    # selects an asset group from the menu selector
    if params[:asset_group].nil?
      # see if one is stored in the session
      @asset_group = session[:asset_group].nil? ? '' : session[:asset_group]
    else
      @asset_group = params[:asset_group]
    end
    # store it in the session for later
    session[:asset_group] = @asset_group


    # Check to see if we got an asset type to sub select on. This occurs when the user
    # selects an asset type from the drop down
    if params[:asset_type].nil?
      # see if one is stored in the session
      @asset_type = session[:asset_type].nil? ? 0 : session[:asset_type].to_i
    else
      @asset_type = params[:asset_type].to_i
    end
    # store it in the session for later
    session[:asset_type] = @asset_type

    # Check to see if we got an asset subtype to sub select on. This will happen if an asset type is selected
    # already and the user selected a subtype from the dropdown.
    if params[:asset_subtype].nil?
      # see if one is stored in the session
      @asset_subtype = session[:asset_subtype].nil? ? 0 : session[:asset_subtype].to_i
    else
      @asset_subtype = params[:asset_subtype].to_i
    end
    # store it in the session for later
    session[:asset_subtype] = @asset_subtype

    # Check to see if we got an organization to sub select on.
    if params[:org_id].nil?
      # see if one is stored in the session
      @org_filter = session[:org_id].nil? ? 0 : session[:org_id].to_i
    else
      @org_filter = params[:org_id].to_i
    end
    # store it in the session for later
    session[:org_id] = @org_filter

    # Check to see if we got a search text and search param to filter on
    if params[:search_text].nil?
      # See if one is stored in the session
      @search_text  = session[:search_text].blank? ?  nil : session[:search_text]
      @search_param = session[:search_param].blank? ? nil : session[:search_param]
    else
      @search_text  = params[:search_text]
      @search_param = params[:search_param]
    end
    # store it in the session for later
    session[:search_text]   = @search_text
    session[:search_param]  = @search_param

    # Check to see if we got list of assets to filter on
    if params[:ids]
      @id_filter_list = params[:ids]
    end

    # Check to see if we got spatial filter. This session variable is managed
    # by the spatial_filter method
    @spatial_filter = session[:spatial_filter]

    # Check to see if we got a different format to render
    if params[:format]
      @fmt = params[:format]
    else
      @fmt = 'html'
    end

    # See if we got start row and count data
    if params[:iDisplayStart] && params[:iDisplayLength]
      @start_row = params[:iDisplayStart]
      @num_rows  = params[:iDisplayLength]
    end

    # If the asset type and subtypes are not set we default to the asset base class
    if @id_filter_list or (@asset_type == 0 and @asset_subtype == 0)
      @asset_class_name = ASSET_BASE_CLASS_NAME
    elsif @asset_subtype > 0
      # we have an asset subtype so get it and get the asset type from it. We also set the filter form
      # to the name of the selected subtype
      subtype = AssetSubtype.find(@asset_subtype)
      @asset_class_name = subtype.asset_type.class_name
      @filter = subtype.name
    else
      asset_type = AssetType.find(@asset_type)
      @asset_class_name = asset_type.class_name
    end
    @view = "#{@asset_class_name.underscore}_index"

  end

  # returns a list of assets for an index view (index, map) based on user selections. Called after
  # a call to set_view_vars
  def get_assets

    # Create a class instance of the asset type which can be used to perform
    # active record queries
    klass = Object.const_get @asset_class_name
    @asset_class = klass.name

    # here we build the query one clause at a time based on the input params
    clauses = []
    values = []

    unless @org_filter == 0
      clauses << ['organization_id = ?']
      values << @org_filter
    else
      clauses << ['organization_id IN (?)']
      values << @organization_list
    end

    if @disposition_year.blank?
      clauses << ['disposition_date IS NULL']
    else
      clauses << ['YEAR(disposition_date) = ?']
      values << @disposition_year
    end

    unless @search_text.blank?
      # get the list of searchable fields from the asset class
      searchable_fields = klass.new.searchable_fields
      # create an OR query for each field
      query_str = []
      first = true
      # parameterize the search based on the selected search parameter
      search_value = get_search_value(@search_text, @search_param)
      # Construct the query based on the searchable fields for the model
      searchable_fields.each do |field|
        if first
          first = false
          query_str << '('
        else
          query_str << ' OR '
        end

        query_str << field
        query_str << ' LIKE ? '
        # add the value in for this sub clause
        values << search_value
      end
      query_str << ')' unless searchable_fields.empty?

      clauses << [query_str.join]
    end

    unless @id_filter_list.blank?
      clauses << ['object_key in (?)']
      values << @id_filter_list
    end

    unless @asset_subtype == 0
      clauses << ['asset_subtype_id = ?']
      values << [@asset_subtype]
    end

    unless @spatial_filter.blank?
      gis_service = GisService.new
      search_box = gis_service.search_box_from_bbox(@spatial_filter)
      wkt = "#{search_box.as_wkt}"
      clauses << ['MBRContains(GeomFromText("' + wkt + '"), geometry) = ?']
      values << [1]
    end

    # See if we got an asset group. If we did then we can
    # use the asset group collection to filter on instead of creating
    # a new query. This is kind of a hack but works!
    unless @asset_group.blank?
      asset_group = AssetGroup.find_by_object_key(@asset_group)
      klass = asset_group.assets unless asset_group.nil?
    end

    # send the query
    @row_count = klass.where(clauses.join(' AND '), *values).count
    if @fmt == 'xls'
      # if it is an xls export get all the rows
      assets = klass.where(clauses.join(' AND '), *values)
    else
      assets = klass.where(clauses.join(' AND '), *values).order("#{sort_column(klass)} #{sort_direction}").page(page).per_page(per_page)
    end
    return assets
  end

  # stores the just-created list of asset ids in the session
  def cache_assets(assets)
    list = []
    unless assets.nil?
      assets.each do |a|
        list << a.object_key
      end
    end
    cache_objects(ASSET_KEY_LIST_VAR, list)
  end

  # called from a show request
  def get_next_and_prev_asset_ids(asset)
    @prev_record_path = "#"
    @next_record_path = "#"
    id_list = get_cached_objects(ASSET_KEY_LIST_VAR)
    # make sure we have a list and an asset to find
    if id_list && asset
      # get the index of the current asset in the array
      current_index = id_list.index(@asset.object_key)
      if current_index
        if current_index > 0
          @prev_record_path = inventory_path(id_list[current_index - 1])
        end
        if current_index < id_list.size
          @next_record_path = inventory_path(id_list[current_index + 1])
        end
      end
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Returns the set of assets, usually paged, as a JSON array compatible
  # with the datatables Jquery plugin.
  def get_as_json(assets, total_rows)
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: total_rows,
      iTotalDisplayRecords: assets.total_entries,
      aaData: data(assets)
    }
  end

  # Renders the assets as an array of arrays where each sub-array is an asset.
  def data(assets)
    assets.map do |a|
      [
        inventory_path(a),
        a.organization.short_name,
        a.asset_subtype.name,
        a.asset_tag,
        a.description,
        a.service_status_type.blank? ?  "" : a.service_status_type.code,
        view_context.format_as_currency(a.cost),

        a.age,
        view_context.format_as_boolean(a.in_backlog),
        view_context.format_as_decimal(a.reported_condition_rating, 1),
        a.reported_condition_type.blank? ?  "" : a.reported_condition_type.name,
        a.estimated_condition_type.blank? ? "" : a.estimated_condition_type.name,
        view_context.format_as_currency(a.estimated_value),

        view_context.format_as_currency(a.estimated_replacement_cost),
        view_context.format_as_fiscal_year(a.policy_replacement_year),
        view_context.format_as_fiscal_year(a.estimated_replacement_year),
        render_to_string(:partial => 'asset_info_detail_popup', :formats => ['html'], :locals => {:asset => a}).html_safe
      ]
    end
  end

  # Determine start row from the input params
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end
  # determine number of rows to return
  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : current_user.num_table_rows
  end

  def sort_column(klass)
    columns = klass.column_names
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  # constructs a query string for a search from a list of searchable fields provided by an asset class
  def get_search_query_string(searchable_fields_list)

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:asset).permit(asset_allowable_params)
  end

  #
  # Overrides the utility method in the base class
  #
  def get_selected_asset(convert=true)
    selected_asset = params[:id].nil? ? nil : Asset.where('organization_id IN (?) AND object_key = ?', @organization_list, params[:id]).first
    if convert
      asset = get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    return asset
  end

  def check_for_cancel
    unless params[:cancel].blank?
      @asset = get_selected_asset(true)
      if @asset.nil?
        redirect_to inventory_index_url
      else
        redirect_to inventory_url(@asset)
      end
    end
  end

  def reformat_date_field
    date_str = params[:asset][:purchase_date]
    form_date = Date.strptime(date_str, '%m-%d-%Y')
    params[:asset][:purchase_date] = form_date.strftime('%Y-%m-%d')
  end
end
