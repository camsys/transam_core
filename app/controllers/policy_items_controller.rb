class PolicyItemsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  # set the @policy variable before any actions are invoked
  before_filter :get_policy,            :only => [:index, :edit, :update, :destroy]  
  before_filter :get_policy_item,       :only => [:edit, :update, :destroy]  
  before_filter :check_for_cancel,      :only => [:create, :update]
  
  def index
        
    # See if the user wants to filter on an asset type
    @asset_type = params[:asset_type]
    if @asset_type.blank?
      @rules = @policy.policy_items
    else
      asset_type = AssetType.find(@asset_type)
      @rules = @policy.policy_items.where('asset_subtype_id IN (?)', asset_type.asset_subtype_ids)
    end
    
    respond_to do |format|
      format.html 
      format.json
      format.xls      
    end
    
  end
  
  def new
            
  end

  def edit

    if @policy_item.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policy_url(@policy)
      return
    end

    add_breadcrumb @policy_item.asset_subtype.name
    add_breadcrumb "Update"
   
  end
  
  def update

    if @policy_item.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policy_url(@policy)
      return
    end

    add_breadcrumb @asset.asset_type.name.pluralize(2), inventory_index_path(:asset_type => @asset.asset_type, :asset_subtype => 0)
    add_breadcrumb @asset.asset_subtype.name.pluralize(2), inventory_index_path(:asset_subtype => @asset.asset_subtype)
    add_breadcrumb @asset.asset_tag, inventory_path(@asset)
    add_breadcrumb @asset_event.asset_event_type.name, edit_inventory_asset_event_path(@asset, @asset_event)
    add_breadcrumb "Update"

    respond_to do |format|
      if @asset_event.update_attributes(form_params)

        notify_user(:notice, "Event was successfully updated.")   

        # The event was updated so we need to update the asset.
        fire_asset_update_event(@asset_event.asset_event_type, @asset)
             
        format.html { redirect_to inventory_url(@asset) }
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

        # The event was removed so we need to update the asset 
        fire_asset_update_event(@asset_event.asset_event_type, @asset)
                
        format.html { redirect_to inventory_url(@asset) }
        format.json { render :json => @asset_event, :status => :created, :location => @asset_event }
      else
        Rails.logger.debug @asset_event.errors.inspect
        format.html { render :action => "new" }
        format.json { render :json => @asset_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    if @policy_item.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policy_url(@policy)
      return
    end

    @policy_item.destroy

    notify_user(:notice, "Rule was successfully removed.")   

    respond_to do |format|
      format.html { redirect_to(policy_url(@policy)) } 
      format.json { head :no_content }
    end
  end
  
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
    
  def get_policy

    @policy = Policy.find_by_object_key(params[:policy_id]) unless params[:policy_id].nil?
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @policy.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policies_url
      return
    end
  end

  def get_policy_item
    @policy_item = @policy.policy_items.find_by_object_key(params[:id]) unless params[:id].nil?
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def reformat_date_field
    date_str = params[:asset_event][:event_date]
    form_date = Date.strptime(date_str, '%m-%d-%Y')
    params[:asset_event][:event_date] = form_date.strftime('%Y-%m-%d')
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
