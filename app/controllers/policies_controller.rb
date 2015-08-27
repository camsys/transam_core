class PoliciesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  #before_filter :authorize_admin
  before_action :get_policy, :except => [:index, :create, :new]

  SESSION_VIEW_TYPE_VAR = 'policies_subnav_view_type'

  def index

    add_breadcrumb "Policies", policies_path

    # get the policies for this agency
    @policies = @organization.policies

  end

  def show

    add_breadcrumb "Policies", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)

  end

  def new
    #right now, no blank policies can be created - just copying existing policies
  end

  #-----------------------------------------------------------------------------
  # Loads an edit form for a policy. called via ajax
  #-----------------------------------------------------------------------------
  def show_edit_form

    @type = params[:type]
    if @type == 'asset_type'
      @rule = @policy.policy_asset_type_rules.find(params[:rule_id])
    elsif @type == 'asset_subtype'
      @rule = @policy.policy_asset_subtype_rules.find(params[:rule_id])
    end

  end

  #-----------------------------------------------------------------------------
  # Updates a policy rule for the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def update_policy_rule

    if params[:policy_asset_type_rule].present?
      rule = PolicyAssetTypeRule.find(params[:policy_asset_type_rule][:id])
      rule.update_attributes(asset_type_rule_form_params)
    else
      rule = PolicyAssetSubtypeRule.find(params[:policy_asset_subtype_rule][:id])
      rule.update_attributes(asset_subtype_rule_form_params)
    end

    render 'update_policy_rules'

  end
  #-----------------------------------------------------------------------------
  # Adds a policy rule to the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def add_policy_rule

    if params[:policy_asset_type_rule].present?
      rule = PolicyAssetTypeRule.new(asset_type_rule_form_params])
    else
      rule = PolicyAssetSubtypeRule.new(asset_subtype_rule_form_params)
    end

    if rule.present?
      rule.policy = @policy
      rule.save
    end

    render 'update_policy_rules'

  end

  # Sets the current policy for an organization
  def make_current

    # Get the concrete class for the organization
    org = Organization.get_typed_organization(@policy.organization)

    # Make sure that any other policies including the selected ones
    # are not current
    org.policies.each do |pol|
      pol.active = false
      pol.save
    end
    # make the selected policy current
    @policy.active = true
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
    new_policy.object_key = nil
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

  def updater
    add_breadcrumb "Policies", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "Asset Updater", updater_policy_path(@policy)

    @builder_proxy = AssetUpdaterProxy.new(:policy => @policy)
    @message = "Updating selected assets. This process might take a while."
  end

  def update_assets

    @builder_proxy = AssetUpdaterProxy.new(params[:asset_updater_proxy])
    if @builder_proxy.valid?
      # Sleep for a couple of seconds so that the screen can display the waiting
      # message and the user can read it.
      sleep 2

      # Run the builder
      options = {}
      options[:asset_type_ids] = @builder_proxy.asset_types
      options[:asset_group_ids] = @builder_proxy.asset_groups

      builder = AssetUpdateJobBuilder.new
      num_to_update = builder.build(@organization, options)

      # Let the user know the results
      if num_to_update > 0
        msg = "#{num_to_update} assets will be updated using policy #{@policy}."
        notify_user(:notice, msg)
        # Add a row into the activity table
        ActivityLog.create({:organization_id => @organization.id, :user_id => current_user.id, :item_type => "Policy Asset Update", :activity => msg, :activity_time => Time.current})
      else
        notify_user(:notice, "No assets were updated.")
      end
      redirect_to policy_path @policy
      return
    else
      respond_to do |format|
        format.html { render :action => "updater" }
      end
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:policy).permit(policy_allowable_params)
  end

  def asset_subtype_rule_form_params
    params.require(:policy_asset_subtype_rule).permit(PolicyAssetSubtypeRule.allowable_params)
  end

  def asset_type_rule_form_params
    params.require(:policy_asset_type_rule).permit(PolicyAssetTypeRule.allowable_params)
  end

  def get_policy
    @policy = Policy.find_by(:object_key => params[:id]) unless params[:id].nil?
  end

end
