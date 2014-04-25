class AssetsController < AssetAwareController
    
  # Include map helpers into this class
  include TransamMapMarkers
  
  # Set the view variabless form the params @asset_type, @asset_subtype, @search_text, @spatial_filter, @view
  before_filter :set_view_vars,     :only => [:index, :map]
  # Don't process cancel buttons  
  before_filter :check_for_cancel,  :only => [:create, :update]
  # set the @asset variable before any actions are invoked
  before_filter :get_asset,         :only => [:show, :edit, :copy, :update, :destroy]
  before_filter :reformat_date_field, :only => [:create, :update]

  # From the application config    
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name   
  MAX_ROWS_RETURNED         = SystemConfig.instance.max_rows_returned
  DEFAULT_SEARCH_RADIUS     = SystemConfig.instance.search_radius
  DEFAULT_SEARCH_UNITS      = Unit.new(SystemConfig.instance.search_units)
  
  STRING_TOKENIZER          = '|'

  # Session Variables
  ASSET_KEY_LIST_VAR        = "asset_key_list_cache_var"
  SESSION_VIEW_TYPE_VAR     = 'assets_subnav_view_type'
  
  # accessed from a show action. Renders the list of assets shown previously
  def back
    id_list = get_cached_objects(ASSET_KEY_LIST_VAR)
    redirect_to inventory_index_url(:ids => id_list)
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
    @page_title = "#{@asset_class.underscore.humanize}".pluralize(2)
   
    markers = []
    @assets.each do |asset|
      if asset.mappable?
        markers << get_map_marker(asset, asset.object_key, false) # not draggable
      end
    end
    @markers = markers.to_json  
    
    # cache the set of asset ids in case we need them later
    cache_assets(@assets)
       
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
    @page_title = "#{@asset_class.underscore.humanize}".pluralize(2)
       
    # cache the set of asset ids in case we need them later
    cache_assets(@assets)
       
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
        
    # create a copy of the asset and null out all the fields that are identified as cleansable
    new_asset = @asset.copy(true)

    notify_user(:notice, "Asset #{@asset.name} was successfully updated.")
        
    @asset = new_asset
    Rails.logger.debug @asset.inspect
    if @asset.geo_locatable? and @asset.mappable?
      markers = []
      markers << get_map_marker(@asset, 'asset', true) # make the marker draggable
      @markers = markers.to_json
    end
    
    # render the edit view
    respond_to do |format|
      format.html { render :action => "edit" }
      format.json { render :json => @asset }
    end
    
  end
  
  def show
    
    @page_title = @asset.name
    @disabled = true
    markers = []
    if @asset.geo_locatable? and @asset.mappable?
      @asset.find_close(DEFAULT_SEARCH_RADIUS, DEFAULT_SEARCH_UNITS).each do |a|
        markers << get_map_marker(a, a.object_key, false, 0, 'purpleIcon')
      end
      # Add the current marker with a high Z index so it shows on top
      markers << get_map_marker(@asset, 'asset', false, 100) # not draggable
    end
    @markers = markers.to_json
        
    # set the @prev_asset_id and @next_asset_id variables
    get_next_and_prev_asset_ids(@asset)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @asset }
    end
    
  end

  def edit
    @page_title = "Update: #{@asset.name}"
    
    if @asset.geo_locatable? and @asset.mappable?
      markers = []
      markers << get_map_marker(@asset, 'asset', true) # make the marker draggable
      @markers = markers.to_json
    end
    
  end

  def update

    @asset.updator = current_user
    if @asset.geo_locatable? and @asset.mappable?
      markers = []
      markers << get_map_marker(@asset, 'asset', true) # make the marker draggable
      @markers = markers.to_json
    end

    respond_to do |format|
      if @asset.update_attributes(form_params)
        
        # If the asset was successfully updated, schedule update the condition and disposition asynchronously
        Delayed::Job.enqueue AssetUpdateJob.new(@asset.object_key), :priority => 0
        
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

    # Use the base class to create an asset of the correct type
    @asset = Asset.new_asset(asset_subtype)
    @asset.organization = @organization
    @disabled = false
    
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
        
    # Check to see if we got a search text to filter on
    if params[:search_text].nil?
      # See if one is stored in the session
      @search_text = session[:search_text].blank? ? nil : session[:search_text]
    else
      @search_text = params[:search_text]
    end
    # store it in the session for later
    session[:search_text] = @search_text
    
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
    clauses << ['organization_id = ?']
    values << [@organization.id]

    unless @search_text.blank?
      # get the list of searchable fields from the asset class
      searchable_fields = klass.new.searchable_fields
      # create an OR query for each field
      query_str = []    
      first = true
    
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
        values << @search_text
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
    #puts 'get_next_and_prev_asset_ids'
    @prev_asset_id = nil
    @next_asset_id = nil
    id_list = get_cached_objects(ASSET_KEY_LIST_VAR)
    #puts id_list.inspect
    #puts @asset.asset_id
    # make sure we have a list and an asset to find
    if id_list && asset
      # get the index of the current asset in the array      
      current_index = id_list.index(@asset.object_key)
      if current_index
        if current_index > 0
          @prev_asset_id = id_list[current_index - 1] 
        end
        if current_index < id_list.size
          @next_asset_id = id_list[current_index + 1]
        end
      end
    end
    #puts @prev_asset_id
    #puts @next_asset_id
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
        a.policy_replacement_year,
        a.estimated_replacement_year
      ]
    end
  end
  
  # Determine start row from the input params
  def page
    params[:iDisplayStart].to_i/per_page + 1
  end
  # determine number of rows to return
  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
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
    selected_asset = params[:id].nil? ? nil : Asset.where('organization_id = ? AND object_key = ?', @organization.id, params[:id]).first
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
