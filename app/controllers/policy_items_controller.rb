class PolicyItemsController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  # set the @policy variable before any actions are invoked
  before_filter :get_policy
  # Set the @policy_item variable
  before_filter :get_policy_item,       :only => [:edit, :update, :destroy]  
  
  def index

    add_breadcrumb @policy.name, policy_path(@policy)
        
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
    
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "New rule"
    
    @policy_item = PolicyItem.new
  end

  def edit

    if @policy_item.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policy_url(@policy)
      return
    end

    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "#{@policy_item} Update"
   
  end
  
  def update

    if @policy_item.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to policy_url(@policy)
      return
    end

    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb @policy_item.asset_subtype, policy_path(@policy)
    add_breadcrumb "Update"

    respond_to do |format|
      if @policy_item.update_attributes(form_params)

        notify_user(:notice, "Rule was successfully updated.")   

        format.html { redirect_to policy_url(@policy) }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render :json => @policy_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create

    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "New rule"

    @policy_item = PolicyItem.new(form_params)
    @policy_item.policy = @policy
    @policy_item.active = true
    
    respond_to do |format|
      if @policy_item.save
        notify_user(:notice, "Rule was sucessfully saved.")
        format.html { redirect_to policy_path(@policy) }
        format.json { render :json => @policy_item, :status => :created }
      else
        format.html { render :action => "new" }
        format.json { render :json => @policy_item.errors, :status => :unprocessable_entity }
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
    @policy_item = @policy.policy_items.find(params[:id]) unless params[:id].nil?
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  
  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:policy_item).permit(PolicyItem.allowable_params)
  end
  
end
