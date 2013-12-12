class AssetEventsController < AssetAwareController
  before_filter :check_for_cancel, :only => [:create, :update]

  # always use generic untyped assets for this controller
  RENDER_TYPED_ASSETS = false
    
  # always render untyped assets for this controller
  def render_typed_assets
    RENDER_TYPED_ASSETS
  end

  def index

    # Check to see if we got an filter to sub select on
    if params[:filter_type].nil? 
      # see if one is stored in the session
      @filter_type = session[:filter_type].nil? ? 0 : session[:filter_type]
    else
      @filter_type = params[:filter_type].to_i
    end
    # store it in the session
    session[:filter_type] = @filter_type

    #if @filter_type == ACTION_FILTER_DISPOSITION
    #  @events = @asset.disposition_updates
    #  @page_title = 'Disposition History:'
    #elsif @filter_type == ACTION_FILTER_CONDITION
    #  @events = @asset.condition_updates
    #  @page_title = 'Condition History:'
    #else
      @events = @asset.history      
      @page_title = 'Asset History:'
    #end    
    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
    end

  end
  
  def new
    
    # get the asset event type
    asset_event_type = AssetEventType.find(params[:event_type])
    if asset_event_type
      @asset_event = AssetEvent.get_new_typed_event(asset_event_type)
      @form_name = asset_event_type.form_name
    end

    @page_sub_title = @asset.name

    respond_to do |format|
      format.html 
      format.json { render :json => @asset_event }
    end
    
  end

  def show

    asset_event = @asset.asset_events.find(params[:id])    
    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if asset_event.nil?
      redirect_to(inventory_asset_events_url(@asset), :flash => { :alert => 'Record not found!'})
      return
    end
 
    @page_title = @asset.name
    # get the typed version of this asset_event
    @asset_event = AssetEvent.as_typed_event(asset_event)
    @form_name = @asset_event.asset_event_type.form_name
    
    @disabled = true
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @asset_event }
    end
  end

  def edit

    asset_event = @asset.asset_events.find(params[:id])         
    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if asset_event.nil?
      redirect_to(inventory_asset_events_url(@asset), :flash => { :alert => 'Record not found!'})
      return
    end

    @page_title = @asset.name
    # get the typed version of this asset_event
    @asset_event = AssetEvent.as_typed_event(asset_event)
    @form_name = @asset_event.asset_event_type.form_name    
    @disabled = false
   
  end
  
  def update

    asset_event = @asset.asset_events.find(params[:id])         
    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if asset_event.nil?
      redirect_to(inventory_asset_events_url(@asset), :flash => { :alert => 'Record not found!'})
      return
    end

    # get the typed version of this asset_event
    @asset_event = AssetEvent.as_typed_event(asset_event)    
    # get the class name for this asset event type
    class_name = asset_event.asset_event_type.class_name
    form_hash = class_name.underscore

    respond_to do |format|
      if @asset_event.update_attributes(params[form_hash])
        # The event was updated so we need to update the asset condition
        Rails.logger.info "Updating condition for asset with key = #{@asset.asset_key}"
        @asset.update_condition_and_disposition
        format.html { redirect_to inventory_asset_event_url(@asset, @asset_event), :notice => "Event was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create

    # we need to know what the action type was for this event
    asset_event_type = AssetEventType.find(params[:event_type])
    # get the class name for this asset event type
    class_name = asset_event_type.class_name
    form_hash = class_name.underscore
    klass = Object.const_get class_name    
    @asset_event = klass.new(params[form_hash])
    @asset_event.asset = @asset
    
    Rails.logger.debug @asset_event.inspect
    
    respond_to do |format|
      if @asset_event.save
        Rails.logger.debug 'Event Saved. Updating asset condition'
        # The event was created so we need to update the asset condition
        @asset.update_condition_and_disposition
        format.html { redirect_to inventory_asset_events_url(@asset), :notice => "Event was successfully created." }
        format.json { render :json => @asset_event, :status => :created, :location => @asset_event }
      else
        Rails.logger.debug @asset_event.errors.inspect
        format.html { render :action => "new" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    @asset_event = @asset.asset_events.find(params[:id])    
    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      redirect_to(inventory_asset_events_url(@asset), :flash => { :alert => 'Record not found!'})
      return
    end

    @asset_event.destroy
    # The event was removed so we need to update the asset condition
    @asset.update_condition_and_disposition

    respond_to do |format|
      format.html { redirect_to(inventory_asset_events_url(@asset), :flash => { :notice => 'Event was successfully removed.'}) } 
      format.json { head :no_content }
    end
  end

private
  
  def check_for_cancel
    # go back to the asset view
    unless params[:cancel].blank?
      redirect_to(inventory_asset_events_url(@asset))
    end    
  end
    
end
