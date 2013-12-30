class PoliciesController < OrganizationAwareController
  #before_filter :authorize_admin
  before_filter :check_for_cancel, :only => [:create, :update]
  before_filter :get_policy, :except => [:index, :create, :new]
  
  SESSION_VIEW_TYPE_VAR = 'policies_subnav_view_type'
  
  # always use generic untyped organizations for this controller
  RENDER_TYPED_ORGANIZATIONS = false
  
  def render_typed_organizations
    RENDER_TYPED_ORGANIZATIONS
  end
  
  def index

    @page_title = 'Policies'
   
    # get the policies for this agency 
    @policies = []
    @organization.policies.each do |p|
      @policies << p
    end   
    
    # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @policies }
    end
  end

  def show

    # Check to see if we got an asset subtype to sub select on
    @asset_subtype = params[:asset_subtype]

    if @asset_subtype
      @policy_items = PolicyItem.where('policy_id = ? AND asset_subtype_id = ? AND active = ?', @policy.id, @asset_subtype, true)
    else
      @policy_items = PolicyItem.where('policy_id = ? AND active = ?', @policy.id, true)
    end   
    @page_title = @policy.name

    # Get the asset types for the filter dropdown
    @asset_types = AssetType.all

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @policy }
    end
  end

  def rules

    @policy_items = PolicyItem.where('policy_id = ? and active = ?', @policy.id, true)
     
    # See if we got a policy item id to edit
    unless params[:policy_item].nil?
      @policy_item = @policy.policy_items.find(params[:policy_item])
      @url = update_rule_policy_url(@policy, :policy_item_id => @policy_item)
    else
      @policy_item = PolicyItem.new
      @url = create_rule_policy_url(@policy)
    end
    @page_title = @policy.name
    
    respond_to do |format|
      format.html # rules.html.erb
      format.json { render :json => @policy }
    end
  end

  # called when the user creates a new rule or updates an existing one
  def update_rule

    # See if we got a policy item id to edit
    if params[:policy_item_id]
      @policy_item = @policy.policy_items.find(params[:policy_item_id])
    end
  
    respond_to do |format|
      if @policy_item.update_attributes(params[:policy_item])
        format.html { redirect_to rules_policy_url(@policy), :notice => "Policy #{@policy.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "rules" }
        format.json { render :json => @policy_item.errors, :status => :unprocessable_entity }
      end
    end
      
  end
  
  def destroy_rule

    # See if we got a policy item id to remove
    if params[:policy_item_id]
      @policy_item = @policy.policy_items.find(params[:policy_item_id])
    end

    respond_to do |format|
      if @policy_item.destroy
        format.html { redirect_to rules_policy_url(@policy), :notice => "Policy #{@policy.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { redirect_to rules_policy_url(@policy), :warning => "Policy #{@policy.name} could not be updated." }
        format.json { head :no_content }
      end
    end
  end

  # called when the user creates a new rule or updates an existing one
  def create_rule

    @policy_item = PolicyItem.new(params[:policy_item])
    @policy_item.policy = @policy
  
    respond_to do |format|
      if @policy_item.save
        format.html { redirect_to rules_policy_url(@policy), :notice => "Policy #{@policy.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "rules" }
        format.json { render :json => @policy_item.errors, :status => :unprocessable_entity }
      end
    end
      
  end
  
  def new

    @page_title = 'New Replacement Policy'

    @policy = Policy.new
    @policy.organization = @organization
    @year_list = create_year_list
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @policy }
    end
  end

  def edit
    
  end

  # Copy a policy to a new policy. This could be copying from a parent agency to a member agency or
  # vis versa
  def copy
    
    old_policy_name = @policy.name
    new_policy = @policy.dup
    new_policy.organization = current_user.organization
    new_policy.name = "Copy of " + @policy.name
    new_policy.description = "Copy of " + @policy.description

    Policy.transaction do
      new_policy.save
      @policy.policy_items.each do |item|
        new_item = item.dup
        new_item.policy = new_policy
        new_item.save
      end        
    end

    # now attempt to load the newly created record
    @policy = current_user.organization.policies.find(new_policy.policy_id)
    respond_to do |format|
      if @policy
        format.html { redirect_to edit_policy_url(@policy), :notice => "Policy #{old_policy_name} was successfully copied." }
        format.json { render :json => @policy, :status => :created, :location => @policy }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
                          
  end
  
  def create

    @policy = Policy.new(params[:policy])
    @policy.agency = @organization

    respond_to do |format|
      if @policy.save
        format.html { redirect_to policy_url(@policy), :notice => "Policy #{@policy.name} was successfully created." }
        format.json { render :json => @policy, :status => :created, :location => @policy }
      else
        format.html { render :action => "new" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @policy.update_attributes(params[:policy])
        format.html { redirect_to policy_url(@policy), :notice => "Policy #{@policy.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    Policy.transaction do
      @policy.policy_items.each do |item|
        item.destroy
      end        
      @policy.destroy
    end

    respond_to do |format|
      format.html { redirect_to policies_url, :notice => "Policy #{@policy.name} was successfully removed." }
      format.json { head :no_content }
    end
  end
  
  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:policy).permit(policy_allowable_params)
  end

  def get_policy
    # See if it is our policy
    @policy = Policy.find(params[:id]) unless params[:id].nil?
    if @policy.nil?
      @policy = Organization.get_typed_organization(@organization).get_policy
    end
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @policy.nil?
      redirect_to(policies_url, :flash => { :alert => 'Record not found!'})
      return
    end
    
  end
  
  def create_year_list
    a = []
    year = Date.today.year
    (0..12).each do |y|
      a << year + y
    end
    return a
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      # get the policy, if one was being edited
      if params[:id]
        redirect_to(policy_url(params[:id]))
      else
        redirect_to(policies_url)
      end
    end
  end
end
