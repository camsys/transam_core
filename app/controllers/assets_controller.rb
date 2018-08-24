class AssetsController < AssetAwareController

  add_breadcrumb "Home", :root_path

  # Set the view variabless form the params @asset_type, @asset_subtype, @search_text, @spatial_filter, @view
  before_action :set_view_vars,     :only => [:index, :map]
  # set the @asset variable before any actions are invoked
  before_action :get_asset,         :only => [:tag, :show, :edit, :copy, :update, :destroy, :summary_info, :add_to_group, :remove_from_group, :popup, :get_dependents, :add_dependents, :get_dependent_subform]
  before_action :reformat_date_fields,  :only => [:create, :update]
  # Update the vendor_id param if the user is using the vendor_name parameter
  before_action :update_vendor_param,  :only => [:create, :update]

  # Lock down the controller
  authorize_resource only: [:index, :show, :new, :create, :edit, :update, :destroy]

  STRING_TOKENIZER          = '|'

  # Session Variables
  INDEX_KEY_LIST_VAR        = "asset_key_list_cache_var"

  # Returns a JSON array of matching asset subtypes based on a typeahead name or description
  def filter

    query = params[:query]
    orgs = params[:search_params][:organization_id] ? [params[:search_params][:organization_id].to_i] : @organization_list
    query_str = "%" + query + "%"
    Rails.logger.debug query_str

    matches = []
    assets = Rails.application.config.asset_base_class_name.constantize
                 .where(organization_id: @organization_list)
                 .where(params[:search_params])
                 .where("(asset_tag LIKE ? OR object_key LIKE ? OR description LIKE ?)", query_str, query_str, query_str)

    assets.each do |asset|
      matches << {
          "id" => asset.object_key,
          "name" => "#{asset.to_s}: #{asset.description}"
      }
    end

    respond_to do |format|
      format.js { render :json => matches.to_json }
      format.json { render :json => matches.to_json }
    end

  end

  # Adds the asset to the specified group
  def add_to_group
    asset_group = AssetGroup.find_by_object_key(params[:asset_group])
    if asset_group.nil?
      notify_user(:alert, "Can't find the asset group selected.")
    else
      if @asset.asset_groups.exists? asset_group.id
        notify_user(:alert, "Asset #{@asset.name} is already a member of '#{asset_group}'.")
      else
        @asset.asset_groups << asset_group
        notify_user(:notice, "Asset #{@asset.name} was added to '#{asset_group}'.")
      end
    end

    # Always display the last view
    redirect_back(fallback_location: root_path)
  end

  # Removes the asset from the specified group
  def remove_from_group
    asset_group = AssetGroup.find_by_object_key(params[:asset_group])
    if asset_group.nil?
      notify_user(:alert, "Can't find the asset group selected.")
    else
      if @asset.asset_groups.exists? asset_group.id
        @asset.asset_groups.delete asset_group
        notify_user(:notice, "Asset #{@asset.name} was removed from '#{asset_group}'.")
      else
        notify_user(:alert, "Asset #{@asset.name} is not a member of '#{asset_group}'.")
      end
    end

    # Always display the last view
    redirect_back(fallback_location: root_path)
  end

  # NOT USED
  def parent
    parent_asset = @organization.assets.find_by_object_key(params[:parent_key])
    respond_to do |format|
      format.js   {render :partial => 'assets/asset_details', :locals => { :asset => parent_asset} }
    end
  end

  def get_summary
    asset_type_id = params[:asset_type_id]

    if asset_type_id.blank?
      results = ActiveRecord::Base.connection.exec_query(Rails.application.config.asset_base_class_name.constantize.operational.select('organization_id, asset_subtypes.asset_type_id, organizations.short_name AS org_short_name, asset_types.name AS subtype_name, COUNT(*) AS assets_count, SUM(purchase_cost) AS sum_purchase_cost, SUM(book_value) AS sum_book_value').joins(:organization, asset_subtype: :asset_type).where(organization_id: @organization_list).group(:organization_id, :asset_type_id).to_sql)
      level = 'type'
    else
      asset_subtype_ids = AssetType.includes(:asset_subtypes).find_by(id: asset_type_id).asset_subtypes.ids
      results = ActiveRecord::Base.connection.exec_query(Rails.application.config.asset_base_class_name.constantize.operational.select('organization_id, asset_subtype_id, organizations.short_name AS org_short_name, asset_subtypes.name AS subtype_name, COUNT(*) AS assets_count, SUM(purchase_cost) AS sum_purchase_cost, SUM(book_value) AS sum_book_value').joins(:organization, :asset_subtype).where(organization_id: (params[:org] || @organization_list), asset_subtype_id: asset_subtype_ids).group(:organization_id, :asset_subtype_id).to_sql)
      level = 'subtype'
    end

    respond_to do |format|
      format.js {
        if params[:org]
          render partial: 'dashboards/assets_widget_table_rows', locals: {results: results, level: level }
        else
          render partial: 'dashboards/assets_widget_table', locals: {results: results, level: level }
        end
      }
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

    terminal_crumb = nil
    if @early_disposition
      terminal_crumb = "Early disposition proposed"
    elsif @transferred_assets
      terminal_crumb = "Transferred Assets"
    elsif @asset_group.present?
      asset_group = AssetGroup.find_by_object_key(@asset_group)
      terminal_crumb = asset_group
    elsif @search_text.present?
      terminal_crumb = "Search '#{@search_text}'"
    elsif @asset_subtype > 0
      subtype = AssetSubtype.find(@asset_subtype)
      add_breadcrumb subtype.asset_type.name.pluralize(2), inventory_index_path(:asset_type => subtype.asset_type, :asset_subtype => 0)
      terminal_crumb = subtype.name
    elsif @manufacturer_id > 0
      add_breadcrumb "Manufacturers", manufacturers_path
      manufacturer = Manufacturer.find(@manufacturer_id)
      terminal_crumb = manufacturer.name
    elsif @asset_type > 0
      asset_type = AssetType.find(@asset_type)
      terminal_crumb = asset_type.name.pluralize(2)

    end
    add_breadcrumb terminal_crumb if terminal_crumb
    
    # check that an order param was provided otherwise use asset_tag as the default
    params[:sort] ||= 'asset_tag'

    # fix sorting on organizations to be alphabetical not by index
    params[:sort] = 'organizations.short_name' if params[:sort] == 'organization_id'

    unless @fmt == 'xls'
      # cache the set of asset ids in case we need them later
      cache_list(@assets.order("#{params[:sort]} #{params[:order]}"), INDEX_KEY_LIST_VAR)
    end

    respond_to do |format|
      format.html
      format.js
      format.json {
        render :json => {
          :total => @assets.count,
          :rows =>  @assets.order("#{params[:sort]} #{params[:order]}").limit(params[:limit]).offset(params[:offset]).as_json(user: current_user, include_early_disposition: @early_disposition)
          }
        }
      format.xls do
        filename = (terminal_crumb || "unknown").gsub(" ", "_").underscore
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}.xls"
      end
      format.xlsx do
        filename = (terminal_crumb || "unknown").gsub(" ", "_").underscore
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}.xlsx"
      end
    end
  end


  def fire_asset_event_workflow_events

    event_name = params[:event]
    asset_event_type = AssetEventType.find_by(id: params[:asset_event_type_id])

    if asset_event_type && params[:targets]

      notification_enabled = asset_event_type.class_name.constantize.workflow_notification_enabled?

      events = asset_event_type.class_name.constantize.where(object_key: params[:targets].split(','))

      failed = 0
      events.each do |evt|

        if evt.fire_state_event(event_name)
          workflow_event = WorkflowEvent.new
          workflow_event.creator = current_user
          workflow_event.accountable = evt
          workflow_event.event_type = event_name
          workflow_event.save

          if notification_enabled
            evt.notify_event_by(current_user, event_name)
          end

        else
          failed += 1
        end
      end

    end

    redirect_back(fallback_location: root_path)
  end

  # makes a copy of an asset and renders it. The new asset is not saved
  # and has any identifying chracteristics identified as CLEANSABLE_FIELDS are nilled
  def copy

    # add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    # add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    # add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    # add_breadcrumb "Copy"

    # create a copy of the asset and null out all the fields that are identified as cleansable
    new_asset = @asset.copy(true)

    notify_user(:notice, "Complete the master record to copy Asset #{@asset.name}.")

    @asset = new_asset

    # render the edit view
    respond_to do |format|
      format.html { render :action => "edit" }
      format.json { render :json => @asset }
    end

  end

  # not used
  def summary_info

    respond_to do |format|
      format.js # show.html.erb
      format.json { render :json => @asset }
    end

  end

  def show

    # add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    # add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    # add_breadcrumb @asset.asset_tag, inventory_path(@asset)

    # Set the asset class view var. This can be used to determine which view components
    # are rendered, for example, which tabs and action items the user sees
    @asset_class_name = @asset.class.name.underscore

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @asset }
    end

  end

  def edit

    # add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    # add_breadcrumb "#{@asset.asset_subtype.name}", inventory_index_path(:asset_subtype => @asset.asset_subtype)
    # When editing a newly transferred asset this link is invalid so we don't want to show it.
    if @asset.asset_tag == @asset.object_key
      @asset.asset_tag = nil
    else
      add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    end
    add_breadcrumb "Update master record", edit_inventory_path(@asset)

  end

  def update

    #add_breadcrumb "#{@asset.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    #add_breadcrumb @asset.name, inventory_path(@asset)
    #add_breadcrumb "Modify", edit_inventory_path(@asset)

    # transfered assets need to remove notification if exists
    # if @asset.asset_tag == @asset.object_key
    #   notification = Notification.where("text = 'A new asset has been transferred to you. Please update the asset.' AND link LIKE ?" , "%#{@asset.object_key}%").first
    #   notification.update(active: false) if notification.present?
    # end

    respond_to do |format|
      if @asset.update_attributes(new_form_params(@asset.class.name))

        # If the asset was successfully updated, schedule update the condition and disposition asynchronously
        Delayed::Job.enqueue AssetUpdateJob.new(@asset.asset.object_key), :priority => 0
        # See if this asset has any dependents that use its spatial reference
        if @asset.geometry and @asset.occupants.count > 0
          # schedule an update to the spatial references of the dependent assets
          Delayed::Job.enqueue AssetDependentSpatialReferenceUpdateJob.new(@asset.asset.object_key), :priority => 0
        end
        notify_user(:notice, "Asset #{@asset.name} was successfully updated.")

        format.html { redirect_to inventory_url(@asset) }
        format.js { notify_user(:notice, "#{@asset} successfully updated.") }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.js { render :action => "edit" }
        format.json { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def get_dependents
    respond_to do |format|
      format.js
      format.json { render :json => @asset.to_json }
    end
  end

  def add_dependents
    params[:asset][:dependents_attributes].each do |key, val|
      unless val[:id]
        dependent = TransamAsset.find_by(object_key: val[:object_key])
        if dependent
          @asset.dependents << dependent
          @asset.update_condition # might need to change to run full AssetUpdateJob
        end
      end
    end

    redirect_back(fallback_location: root_path)
  end

  def get_dependent_subform

    @dependent = @asset.dependents.find_by(params[:dependent_object_key])

    @dependent_subform_target = params[:dependent_subform_target]
    @dependent_subform_view = params[:dependent_subform_view]

    respond_to do |format|
      format.js
    end

  end

  def new_asset
    authorize! :new, Asset
    
    add_breadcrumb "Add Asset", new_asset_inventory_index_path

  end

  def new

    asset_class = Rails.application.config.asset_seed_class_name.constantize.find_by(id: params[:asset_base_class_id])
    if asset_class.nil?
      notify_user(:alert, "Asset class '#{params[:asset_base_class_id]}' not found. Can't create new asset!")
      redirect_to(root_url)
      return
    end

    #add_breadcrumb "#{asset_subtype.asset_type.name}".pluralize(2), inventory_index_path(:asset_type => asset_subtype.asset_type)
    #add_breadcrumb "#{asset_subtype.name}", inventory_index_path(:asset_subtype => asset_subtype)
    #add_breadcrumb "New", new_inventory_path(asset_subtype)

    # Use the asset class to create an asset of the correct type
    @asset = Rails.application.config.asset_base_class_name.constantize.new_asset(asset_class, params)

    # See if the user selected an org to associate the asset with
    if params[:organization_id].present?
      @asset.organization = Organization.find(params[:organization_id])
    else
      @asset.organization_id = @organization_list.first
    end

    if params[:parent_id].present?
      @asset.parent_id = params[:parent_id].to_i
    end

    respond_to do |format|
      format.html # new.html.haml this had been an erb and is now an haml the change should just be caught
      format.json { render :json => @asset }
    end
  end

  def create

    asset_class = Rails.application.config.asset_seed_class_name.constantize.find_by(id: params[:asset][Rails.application.config.asset_seed_class_name.foreign_key.to_sym])
    if asset_class.nil?
      notify_user(:alert, "Asset class '#{params[:asset_base_class_id]}' not found. Can't create new asset!")
      redirect_to(root_url)
      return
    end

    # Use the asset class to create an asset of the correct type
    @asset = Rails.application.config.asset_base_class_name.constantize.new_asset(asset_class, new_form_params(asset_class.class_name).except(:dependents_attributes))

    # If the asset does not have an org already defined, set to the default for
    # the user
    if @asset.organization.blank?
      @asset.organization_id = @organization_list.first
    end

    #@asset.creator = current_user
    #@asset.updator = current_user

    #Rails.logger.debug @asset.inspect

    # add_breadcrumb "#{asset_type.name}".pluralize(2), inventory_index_path(:asset_type => asset_subtype.asset_type)
    # add_breadcrumb "#{asset_subtype.name}", inventory_index_path(:asset_subtype => asset_subtype)
    # add_breadcrumb "New", new_inventory_path(asset_subtype)

    respond_to do |format|
      if @asset.save

        # Make sure the policy has rules for this asset
        policy = @asset.policy
        policy.find_or_create_asset_type_rule @asset.asset_subtype.asset_type
        policy.find_or_create_asset_subtype_rule @asset.asset_subtype

        # If the asset was successfully saved, schedule update the condition and disposition asynchronously
        #Delayed::Job.enqueue AssetUpdateJob.new(@asset.object_key), :priority => 0

        notify_user(:notice, "Asset #{@asset.to_s} was successfully created.")

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
      redirect_to(inventory_index_url, :flash => { :alert => t(:error_404) })
      return
    end

    # Destroy this asset, call backs to remove each associated object will be made
    @asset.destroy

    notify_user(:notice, "Asset was successfully removed.")

    respond_to do |format|
      format.html { redirect_to(inventory_index_url) }
      format.json { head :no_content }
    end

  end

  # Adds the assets to the user's tag list or removes it if the asset
  # is already tagged. called by ajax so no response is rendered
  # NOT USED
  def tag

    if @asset.tagged? current_user
      @asset.users.delete current_user
    else
      @asset.tag current_user
    end

    # No response needed
    render :nothing => true

  end

  # Called via AJAX to get dynamic content via AJAX
  # NOT USED (I think)
  def popup

    str = ""
    if @asset
      str = render_to_string(:partial => "popup", :locals => { :asset => @asset })
    end

    render json: str.to_json

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
    if params[:asset_group].nil? or params[:asset_group] == '0'
      @asset_group = ''
    else
      @asset_group = params[:asset_group]
    end

    # Check to see if we got an asset type to sub select on. This occurs when the user
    # selects an asset type from the drop down
    if params[:asset_type].nil?
      @asset_type =  0
    else
      @asset_type = params[:asset_type].to_i
    end

    # Check to see if we got an asset subtype to sub select on. This will happen if an asset type is selected
    # already and the user selected a subtype from the dropdown.
    if params[:asset_subtype].nil?
      @asset_subtype = 0
    else
      @asset_subtype = params[:asset_subtype].to_i
    end

    # Check to see if we got an organization to sub select on.
    if params[:org_id].nil?
      @org_id = 0
    else
      @org_id = params[:org_id].to_i
    end

    # Check to see if we got a manufacturer to sub select on.
    if params[:manufacturer_id].nil?
      @manufacturer_id = 0
    else
      @manufacturer_id = params[:manufacturer_id].to_i
    end

    # Check to see if we got a service status to sub select on.
    if params[:service_status].nil?
      @service_status = 0
    else
      @service_status = params[:service_status].to_i
    end

    # Check to see if we got a search text and search param to filter on
    if params[:search_text].nil?
      # See if one is stored in the session
      @search_text  = session[:search_text].blank? ?  nil : session[:search_text]
      @search_param = session[:search_param].blank? ? nil : session[:search_param]
    else
      @search_text  = params[:search_text]
      @search_param = params[:search_param]
    end

    # Check to see if we got list of assets to filter on
    if params[:ids]
      #Checks to see if the id list is already an array.  Converts a string to
      # an array if necessary.
      if params[:ids].is_a?(Array)
        @id_filter_list = params[:ids]
      else
        @id_filter_list = params[:ids].split("|")
      end

    else
      @id_filter_list = []
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

    # Check to see if search for early disposition proposed assets only
    if params[:early_disposition] == '1'
      @early_disposition = true
    end
    if params[:transferred_assets] == '1'
      @transferred_assets = true
    end

    # If the asset type and subtypes are not set we default to the asset base class
    if @id_filter_list.present? or (@asset_type == 0 and @asset_subtype == 0)
      # THIS WILL NO LONGER WORK
      # asset base class name should really be seed to pull typed asset class
      # base class here is just Asset or the new TransamAsset
      @asset_class_name = 'TransamAsset'
    elsif @asset_subtype > 0
      # we have an asset subtype so get it and get the asset type from it. We also set the filter form
      # to the name of the selected subtype
      subtype = AssetSubtype.find(@asset_subtype)
      @asset_type = subtype.asset_type.id
      @asset_class_name = subtype.asset_type.class_name
      @filter = subtype.name
    else
      asset_type = AssetType.find(@asset_type)
      @asset_class_name = asset_type.class_name
    end
    @view = "#{@asset_class_name.underscore}_index"

    Rails.logger.debug "@fmt = #{@fmt}"
    Rails.logger.debug "@asset_type = #{@asset_type}"
    Rails.logger.debug "@asset_subtype = #{@asset_subtype}"
    Rails.logger.debug "@asset_class_name = #{@asset_class_name}"
    Rails.logger.debug "@view = #{@view}"

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
    unless @org_id == 0
      clauses << ['organization_id = ?']
      values << @org_id
    else
      clauses << ['organization_id IN (?)']
      values << @organization_list
    end

    unless @manufacturer_id == 0
      clauses << ['manufacturer_id = ?']
      values << @manufacturer_id
    end

    unless @service_status == 0
      clauses << ['service_status_type_id = ?']
      values << @service_status
    end

    if @disposition_year.blank?
      clauses << ['assets.disposition_date IS NULL']
    else
      clauses << ['YEAR(assets.disposition_date) = ?']
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

    unless @asset_type == 0
      clauses << ['assets.asset_type_id = ?']
      values << [@asset_type]
    end

    if @transferred_assets
      clauses << ['assets.service_status_type_id IS NULL']
      clauses << ['assets.asset_tag = assets.object_key']
    else
      clauses << ['assets.asset_tag != assets.object_key']
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

    # Search for only early dispostion proposed assets if flag is on
    if @early_disposition
      klass = klass.joins(:early_disposition_requests).where(asset_events: {state: 'new'})
    end

    # send the query
    klass.where(clauses.join(' AND '), *values)
      .includes(:asset_type, :organization, :asset_subtype, :service_status_type, :manufacturer)
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

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:asset).permit(asset_allowable_params)
  end

  def new_form_params(klass)
    params.require(:asset).permit(klass.constantize.new.allowable_params)
  end

  #
  # Overrides the utility method in the base class
  #
  def get_selected_asset(convert=true)
    selected_asset = Rails.application.config.asset_base_class_name.constantize.find_by(:organization_id => @organization_list, :object_key => params[:id]) unless params[:id].blank?
    if convert
      asset = Rails.application.config.asset_base_class_name.constantize.get_typed_asset(selected_asset)
    else
      asset = selected_asset
    end
    return asset
  end

  def reformat_date(date_str)
    # See if it's already in iso8601 format first
    return date_str if date_str.match(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.strptime(date_str, '%m/%d/%Y').strftime('%Y-%m-%d')
  end

  def reformat_date_fields
    params[:asset][:purchase_date] = reformat_date(params[:asset][:purchase_date]) unless params[:asset][:purchase_date].blank?
    params[:asset][:in_service_date] = reformat_date(params[:asset][:in_service_date]) unless params[:asset][:in_service_date].blank?
    params[:asset][:warranty_date] = reformat_date(params[:asset][:warranty_date]) unless params[:asset][:warranty_date].blank?
  end

  # Manage the vendor_id/vendor_name
  def update_vendor_param

    # If the vendor_name is set in the params then the model needs to override the
    # vendor_id param. If both the vendor_id and vendor_name are unset then the
    # model needs to remove the vendor. If the vendor_id is set, leave it alone
    if params[:asset][:vendor_name].present?
      vendor = Vendor.find_or_create_by(:name => params[:asset][:vendor_name], :organization => @organization)
      params[:asset][:vendor_id] = vendor.id
    elsif params[:asset][:vendor_id].blank? and params[:asset][:vendor_name].blank?
      params[:asset][:vendor_id] = nil
    end
    # vendor_name has served its purpose (find/set vendor_id), so remove from hash
    params[:asset].delete :vendor_name

  end
end
