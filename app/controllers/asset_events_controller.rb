class AssetEventsController < AssetAwareController

  # set the @asset_event variable before any actions are invoked
  before_filter :get_asset_event,   :only => [:show, :edit, :update, :destroy]  
  before_filter :check_for_cancel,  :only => [:create, :update]

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

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_asset_events_url(@asset))
      return
    end
 
    @page_title = @asset.name
    @form_name = @asset_event.asset_event_type.form_name
    
    @disabled = true
    
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
      redirect_to(inventory_asset_events_url(@asset))
      return
    end

    @page_title = @asset.name
    @form_name = @asset_event.asset_event_type.form_name    
    @disabled = false
   
  end
  
  def update

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_asset_events_url(@asset))
      return
    end

    respond_to do |format|
      if @asset_event.update_attributes(form_params)

        notify_user(:notice, "Event was successfully updated.")   

        # The event was updated so we need to update the asset condition
        Delayed::Job.enqueue AssetConditionUpdateJob.new(@asset.object_key), :priority => 0
             
        format.html { redirect_to inventory_asset_event_url(@asset, @asset_event) }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create

    # we need to know what the event type was for this event
    asset_event_type = AssetEventType.find(params[:event_type])
    # get the class name for this asset event type
    class_name = asset_event_type.class_name
    klass = Object.const_get class_name    
    @asset_event = klass.new(form_params)
    @asset_event.asset = @asset
    
    Rails.logger.debug @asset_event.inspect
    
    respond_to do |format|
      if @asset_event.save
        
        notify_user(:notice, "Event was successfully created.")   
        
        # The event was created so we need to update the asset condition
        Delayed::Job.enqueue AssetConditionUpdateJob.new(@asset.object_key), :priority => 0
        
        format.html { redirect_to inventory_asset_events_url(@asset)}
        format.json { render :json => @asset_event, :status => :created, :location => @asset_event }
      else
        Rails.logger.debug @asset_event.errors.inspect
        format.html { render :action => "new" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    # if not found or the object does not belong to the asset
    # send them back to index.html.erb
    if @asset_event.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_asset_events_url(@asset))
      return
    end

    @asset_event.destroy

    notify_user(:notice, "Event was successfully removed.")   

    # The event was removed so we need to update the asset condition
    Delayed::Job.enqueue AssetConditionUpdateJob.new(@asset.object_key), :priority => 0

    respond_to do |format|
      format.html { redirect_to(inventory_asset_events_url(@asset)) } 
      format.json { head :no_content }
    end
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  def get_asset_event
    asset_event = AssetEvent.find_by_object_key(params[:id]) unless params[:id].nil?
    if asset_event
      @asset_event = AssetEvent.as_typed_event(asset_event)
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:asset_event).permit(asset_event_allowable_params)
  end
  
  def check_for_cancel
    # go back to the asset view
    unless params[:cancel].blank?
      redirect_to(inventory_asset_events_url(@asset))
    end    
  end
    
end
