class PoliciesController < OrganizationAwareController
  
  add_breadcrumb "Home", :root_path
  
  #before_filter :authorize_admin
  before_filter :check_for_cancel, :only => [:create, :update]
  before_filter :get_policy, :except => [:index, :create, :new]
  
  SESSION_VIEW_TYPE_VAR = 'policies_subnav_view_type'
    
  def index

    @page_title = 'Policies'
    add_breadcrumb "Policies", policies_path
   
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

    @page_title = @policy.name
    add_breadcrumb "Policies", policies_path
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
      format.html # show.html.erb
      format.js
      format.json { render :json => @policy }
    end
  end

  
  def new
    #right now, no blank policies can be created - just copying existing policies
  end

  # Sets the current policy for an organization
  def make_current

    # Get the concrete class for the organization
    org = Organization.get_typed_organization(@policy.organization)
    
    # Make sure that any other policies including the selected ones
    # are not current
    org.policies.each do |pol|
      pol.current = false
      pol.save
    end
    # make the selected policy current
    @policy.current = true
    @policy.save
    
    notify_user(:notice, "Policy #{@policy.name} is now set as the current policy.")
    redirect_to policy_url(@policy)    
        
  end

  def edit
    
    add_breadcrumb "Policies", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb 'Modify', edit_policy_path(@policy)
    
  end

  # Copy a policy to a new policy. This could be copying from a parent agency to a member agency or
  # vis versa
  def copy
    
    old_policy_name = @policy.name
    new_policy = @policy.dup
    new_policy.parent = @policy
    new_policy.organization = @organization
    new_policy.name = "Copy of " + @policy.name
    new_policy.description = "Copy of " + @policy.description
    new_policy.current = false
    new_policy.active = true
        
    new_policy.policy_items.clear

    new_policy.save!

    # now attempt to load the newly created record
    @policy = Policy.find(new_policy.id)
    respond_to do |format|
      if @policy
        notify_user(:notice, "Policy #{old_policy_name} was successfully copied.")
        format.html { redirect_to edit_policy_url(@policy) }
        format.json { render :json => @policy, :status => :created, :location => @policy }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
                          
  end
  
  def create

    @policy = Policy.new(form_params)
    @policy.organization = @organization

    respond_to do |format|
      if @policy.save
        notify_user(:notice, "Policy #{@policy.name} was successfully created.")
        format.html { redirect_to policy_url(@policy) }
        format.json { render :json => @policy, :status => :created, :location => @policy }
      else
        format.html { render :action => "new" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    add_breadcrumb "Policies", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb 'Modify', edit_policy_path(@policy)

    respond_to do |format|
      if @policy.update_attributes(form_params)
        notify_user(:notice, "Policy #{@policy.name} was successfully updated.")
        format.html { redirect_to policy_url(@policy) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    @policy.destroy
    notify_user(:notice, "Policy was successfully removed.")
    respond_to do |format|
      format.html { redirect_to policies_url }
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
    @policy = Policy.find_by_object_key(params[:id]) unless params[:id].nil?
    if @policy.nil?
      @policy = Organization.get_typed_organization(@organization).get_policy
    end
    # if not found or the object does not belong to the users
    # send them back to index.html.erb
    if @policy.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(policies_url)
      return
    end
    
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
