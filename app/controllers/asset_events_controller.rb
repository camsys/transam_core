class AssetEventsController < AssetAwareController

  add_breadcrumb "Home", :root_path

  # set the @asset_event variable before any actions are invoked
  before_action :get_asset_event,       :only => [:show, :edit, :update, :destroy, :fire_workflow_event, :popup]
  before_action :check_for_cancel,      :only => [:create, :update]
  before_action :reformat_date_field,   :only => [:create, :update]

  skip_before_action :get_asset,        :only => [:get_summary, :popup]

  # always use generic untyped assets for this controller
  RENDER_TYPED_ASSETS = true

  # Lock down the controller
  authorize_resource only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # always render untyped assets for this controller
  def render_typed_assets
    RENDER_TYPED_ASSETS
  end

  def get_summary
    asset_event_type = AssetEventType.find_by(id: params[:asset_event_type_id])

    unless asset_event_type.nil?
      asset_event_klass = asset_event_type.class_name.constantize

      if params[:order].blank?
        results = asset_event_klass.all
      else
        results = asset_event_klass.unscoped.order(params[:order])
      end

      if asset_event_klass.count > 0
        asset_klass = asset_event_klass.first.send(Rails.application.config.asset_base_class_name.underscore).class

        asset_joins = [Rails.application.config.asset_base_class_name.underscore]

        while asset_klass.try(:acting_as_name)
          asset_joins << asset_klass.acting_as_name
          asset_klass = asset_klass.acting_as_name.classify.constantize
        end


        idx = asset_joins.length-2
        join_relations = Hash.new
        join_relations[asset_joins[idx]] = asset_joins[idx+1]
        idx -= 1
        while idx >= 0
          tmp = Hash.new
          tmp[asset_joins[idx]] = join_relations
          join_relations = tmp
          idx -= 1
        end

        results = results.includes(join_relations).where(transam_asset: asset_event_klass.first.send(Rails.application.config.asset_base_class_name.underscore).class.where(organization_id: @organization_list))
      end

      unless params[:scope].blank?
        if asset_event_klass.respond_to? params[:scope]
          results = results.send(params[:scope])
        end
      end




      respond_to do |format|
        format.js {
          render partial: "dashboards/#{asset_event_type.class_name.underscore}_widget_table", locals: {results: results }
        }
      end

    end
  end

  def popup

  end

  def index

    add_asset_breadcrumbs
    add_breadcrumb "History"

    # Check to see if we got a filter to sub select on
    if params[:filter_type]
      # see if it was blank
      if params[:filter_type].blank?
        @filter_type = 0
      else
        @filter_type = params[:filter_type].to_i
      end
    else
      # See if there is one in the session
      @filter_type = session[:filter_type].nil? ? 0 : session[:filter_type]
    end
    # store it in the session
    session[:filter_type] = @filter_type

    if @filter_type == 0
      @events = @asset.asset_events
    else
      @events = @asset.asset_events.where('asset_event_type_id = ?', @filter_type)
    end

    @page_title = "#{@asset.name}: History"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
    end

  end

  def new

    # get the asset event type
    asset_event_type = AssetEventType.find(params[:event_type])
    unless asset_event_type.blank?
      @asset_event = @asset.build_typed_event(asset_event_type.class_name.constantize)
    end

    if params[:transferred] == '1'
      @transferred = true
    end

    unless params[:causal_asset_event_id].nil?
      @causal_asset_event_id = params[:causal_asset_event_id]
    end

    unless params[:causal_asset_event_name].nil?
      @causal_asset_event_name = params[:causal_asset_event_name]
    end

    add_new_show_create_breadcrumbs

    respond_to do |format|
      @ajax_request = ajax_request?
      format.html
      format.js
      format.json { render :json => @asset_event }
    end

  end

  def show

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_url(@asset))
      return
    end

    add_new_show_create_breadcrumbs

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @asset_event }
    end
  end

  def edit

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_url(@asset))
      return
    end

    add_edit_update_breadcrumbs

    respond_to do |format|
      @ajax_request = ajax_request?
      format.html
      format.js
      format.json { render :json => @asset_event }
    end

  end

  def update

    # get variables for updating view via JS if form sent remotely
    @ajax_request = ajax_request?
    if @ajax_request
      @view_div = params[:view_div]
      @view_name = params[:view_name]
    end

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_url(@asset))
      return
    end

    @asset_event.updater = current_user

    add_edit_update_breadcrumbs

    respond_to do |format|
      if @asset_event.update_attributes(form_params)

        notify_user(:notice, "Event was successfully updated.")

        # The event was updated so we need to update the asset.
        #fire_asset_update_event(@asset_event.asset_event_type, @asset)

        format.html { redirect_to inventory_url(@asset) }
        format.js
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.js { render "edit" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create

    # get variables for updating view via JS if form sent remotely

    @ajax_request = ajax_request?
    if @ajax_request
      @view_div = params[:view_div]
      @view_name = params[:view_name]
    end

    # we need to know what the event type was for this event
    asset_event_type = AssetEventType.find(params[:event_type])
    unless asset_event_type.blank?
      assoc_name = asset_event_type.class_name.gsub('Event', '').underscore.pluralize
      assoc_name = 'early_disposition_requests' if assoc_name == 'early_disposition_request_updates'
      owner = @asset.send(assoc_name).proxy_association.owner
      asset_params = Hash.new
      asset_params[Rails.application.config.asset_base_class_name.underscore] = owner
      @asset_event = asset_event_type.class_name.constantize.new(form_params.merge(asset_params))
      @asset_event.creator = current_user
    end

    unless params[:causal_asset_event_id].nil?
      @causal_asset_event = AssetEvent.find_by(:object_key => params[:causal_asset_event_id])
    end

    unless params[:causal_asset_event_name].nil?
      @causal_asset_event_name = params[:causal_asset_event_name]
    end

    add_new_show_create_breadcrumbs

    respond_to do |format|
      if @asset_event.save
        Rails.logger.debug @asset_event.inspect

        notify_user(:notice, "Event was successfully created.")

        # The event was removed so we need to update the asset
        #fire_asset_update_event(@asset_event.asset_event_type, @asset)

        # if notification enabled, then send out
        if @asset_event.class.try(:workflow_notification_enabled?)
          @asset_event.notify_event_by(current_user, :new)
        end

        #If another event resulted in this event we should provess the other event as well
        unless @causal_asset_event.nil? || @causal_asset_event_name.nil?
          @causal_asset_event = AssetEvent.as_typed_event @causal_asset_event
          if @causal_asset_event.class.name == 'EarlyDispositionRequestUpdateEvent' && @causal_asset_event_name == 'approve_via_transfer'
            @causal_asset_event.state = 'transfer_approved'
            @causal_asset_event.save
          end
        end

        format.html { redirect_to inventory_url(@asset) }
        format.js
        format.json { render :json => @asset_event, :status => :created, :location => @asset_event }
      else
        Rails.logger.debug @asset_event.errors.inspect
        format.html { render :action => "new" }
        format.js { render :action => "new" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_url(@asset))
      return
    end

    asset_event_type = @asset_event.asset_event_type
    @asset_event.destroy

    notify_user(:notice, "Event was successfully removed.")

    # The event was removed so we need to update the asset condition
    #fire_asset_update_event(asset_event_type, @asset)

    respond_to do |format|
      format.html { redirect_to(inventory_url(@asset)) }
      format.json { head :no_content }
    end
  end

  def fire_workflow_event

    # Check that this is a valid event name for the state machines
    asset_event_class = @asset_event.class

    if asset_event_class.try(:event_names) && asset_event_class.event_names.include?(params[:event])
      event_name = params[:event]

      # special cases
      # jump to final disposition page if a manager approves an early disposition request via transfer
      if asset_event_class.name == 'EarlyDispositionRequestUpdateEvent' && event_name == "approve_via_transfer"
        is_redirected = true
        # we do not want to fire approval of the application event approval
        redirect_to new_inventory_asset_event_path(@asset_event.send(Rails.application.config.asset_base_class_name.underscore), :event_type => DispositionUpdateEvent.asset_event_type.id, :transferred => 1, :causal_asset_event_id => @asset_event.object_key, :causal_asset_event_name => event_name)
      elsif @asset_event.fire_state_event(event_name)

        @asset_event.update_columns(updated_by_id: current_user.id)

        event = WorkflowEvent.new
        event.creator = current_user
        event.accountable = @asset_event
        event.event_type = event_name
        event.save

        # if notification enabled, then send out
        if asset_event_class.try(:workflow_notification_enabled?)
          @asset_event.notify_event_by(current_user, event_name)
        end

      else
        notify_user(:alert, "Could not #{event_name.humanize} asset event #{@asset_event}")
      end

    else
      notify_user(:alert, "#{params[:event_name]} is not a valid event for a #{asset_event_class.name}")
    end

    unless is_redirected
      redirect_back fallback_location: root_path
    end

  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Updates the asset by running the appropriate job. The job is based on the
  # type of event that was modified. If the job requires the asset SOGR metrics be updated
  # then the SOGR update job is queued for the asset
  def fire_asset_update_event(asset_event_type, asset, priority = 0)
    if asset_event_type && asset && !asset_event_type.job_name.blank?
      klass = asset_event_type.job_name.constantize
      job = klass.new(asset.object_key)
      begin
        # Run the job
        job.perform
        # See if the job also needs to update the assets SOGR
        if job.requires_sogr_update?
          next_job = AssetSogrUpdateJob.new(asset.object_key)
          fire_background_job(next_job, priority)
        end
      rescue Exception => e
        Rails.logger.warn e.message
      end
    end
  end


  def get_asset_event
    asset_event = AssetEvent.find_by_object_key(params[:id]) unless params[:id].nil?
    if asset_event
      @asset_event = AssetEvent.as_typed_event(asset_event)
    else
      redirect_to '/404'
    end
  end

  def add_asset_breadcrumbs
    add_breadcrumb @asset.asset_type.name.pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb @asset.asset_subtype.name.pluralize(2), inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
  end

  def add_new_show_create_breadcrumbs
    add_asset_breadcrumbs
    add_breadcrumb "#{@asset_event.asset_event_type.name} Update"
  end

  def add_edit_update_breadcrumbs
    add_asset_breadcrumbs
    add_breadcrumb @asset_event.asset_event_type.name, edit_inventory_asset_event_path(@asset, @asset_event)
    add_breadcrumb "Update"
  end


  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def reformat_date_field
    date_str = params[:asset_event][:event_date]
    if date_str.present?
      form_date = Date.strptime(date_str, '%m/%d/%Y')
      params[:asset_event][:event_date] = form_date.strftime('%Y-%m-%d')
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:asset_event).permit(asset_event_allowable_params)
  end

  def check_for_cancel
    # go back to the asset view
    unless params[:cancel].blank?
      redirect_to(inventory_url(@asset))
    end
  end

end
