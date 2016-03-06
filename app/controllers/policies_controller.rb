class PoliciesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  #before_filter :authorize_admin
  before_action :get_policy, :except => [:index, :create, :new]

  SESSION_VIEW_TYPE_VAR = 'policies_subnav_view_type'

  def index

    add_breadcrumb "Policies", policies_path

    # create hash to store policies from organization_list
    policies = Hash.new
    @organization_list.each do |o|
		  org = Organization.get_typed_organization(Organization.find(o))
      policies[org.short_name] = org.policies
    end

    @policies = policies

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
      @rule = @policy.policy_asset_type_rules.find(params[:rule])
    elsif @type == 'asset_subtype'
      @rule = @policy.policy_asset_subtype_rules.find(params[:rule])
      @asset_type = @rule.asset_subtype.asset_type
      # Check to see if the user wants to create a copy
      if params[:copy].to_i == 1
        @copy = @rule.id
        rule = @rule.dup
        #rule.save
        @rule = rule

      end
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
  # Removes a policy rule from the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def remove_policy_rule

    rule = @policy.policy_asset_subtype_rules.find(params[:rule])
    if rule.nil?
      notify_user_immediately "Can't find the rule in policy #{@policy}", "warning"
    elsif rule.default_rule
      notify_user_immediately "Can't remove a default rule from #{@policy}", "warning"
    else
      rule.destroy
      notify_user_immediately "Rule was sucessfully removed from #{@policy}"
    end

    render 'update_policy_rules'

  end

  #-----------------------------------------------------------------------------
  # Adds a policy rule to the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def add_policy_rule

    if params[:policy_asset_type_rule].present?
      rule = PolicyAssetTypeRule.new(asset_type_rule_form_params)
    elsif params[:copied_rule].present? # if the rule is copied, copy from old rule and overwrite with form
      rule = PolicyAssetSubtypeRule.find(params[:copied_rule]).dup
      rule.default_rule = false
      rule.assign_attributes(asset_subtype_rule_form_params)
    else
      rule = PolicyAssetSubtypeRule.new(asset_subtype_rule_form_params)
    end

    if rule.present?
      rule.policy = @policy
      rule.save
    end

    render 'update_policy_rules'

  end

  #-----------------------------------------------------------------------------
  # Shows the form for new policy rules. Called via ajax
  #-----------------------------------------------------------------------------
  def new_policy_rule

    @valid_types = []
    if params[:type] == '1'
      @rule = PolicyAssetTypeRule.new(:policy => @policy)
      @rule_type = 'asset_type'
      AssetType.active.each do |at|
        @valid_types << at unless @policy.asset_type_rule? at
      end
    else
      @asset_type = AssetType.find(params[:asset_type])
      @rule = PolicyAssetSubtypeRule.new(:policy => @policy)
      @rule_type = 'asset_subtype'
      AssetSubtype.active.where(:asset_type_id => @asset_type).each do |at|
        @valid_types << at unless @policy.asset_subtype_rule? at
      end
    end
    render 'new_rule'
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

    if params[:copy].to_i == 1
      add_breadcrumb 'Copy', edit_policy_path(@policy, :copy => '1')

      @copy = @policy.object_key
      new_policy = @policy.dup
      new_policy.object_key = nil
      new_policy.parent = @policy.parent
      new_policy.organization = @organization
      new_policy.description = "Copy of " + @policy.description
      new_policy.active = false
      @policy = new_policy #set policy to newly copied policy

    else
      add_breadcrumb 'Modify', edit_policy_path(@policy)
    end

  end

  # Copy a policy to a new policy. This could be copying from a parent agency to a member agency or
  # vis versa
  def copy

    old_policy_name = @policy.name
    new_policy = @policy.dup
    new_policy.object_key = nil
    new_policy.parent = @policy.parent
    new_policy.organization = @organization
    new_policy.active = false

    new_policy.assign_attributes(form_params)

    new_policy.save!
    # Copy all the records
    @policy.policy_asset_type_rules.each do |r|
      rule = r.dup
      rule.policy = new_policy
      rule.save
    end
    @policy.policy_asset_subtype_rules.each do |r|
      rule = r.dup
      rule.policy = new_policy
      rule.save
    end

    # now attempt to load the newly created record
    @policy = Policy.find(new_policy.id)
    respond_to do |format|
      if @policy
        notify_user(:notice, "Policy #{old_policy_name} was successfully copied.")
        format.html { redirect_to policy_url(@policy) }
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

  def runner
    add_breadcrumb "Policies", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "Policy Runner", runner_policy_path(@policy)

    @builder_proxy = AssetUpdaterProxy.new(:policy => @policy)
    @asset_types = AssetType.active.where(id: @organization.asset_type_counts.keys)
    @message = "Applying policy to selected assets. This may take a while..."
  end

  def update_assets

    @builder_proxy = AssetUpdaterProxy.new(params[:asset_updater_proxy])
    if @builder_proxy.valid?
      # Sleep for a couple of seconds so that the screen can display the waiting
      # message and the user can read it.
      sleep 2

      # Rip through the organizations assets, creating a job for each type requested
      org = Organization.get_typed_organization(@policy.organization)
      assets = org.assets.operational.where(asset_type: @builder_proxy.asset_types)
      count = assets.count
      assets.find_each do |a|
        typed_asset = Asset.get_typed_asset(a)
        typed_asset.update_methods.each do |m|
          begin
            typed_asset.send(m)
          rescue Exception => e
            Rails.logger.warn e.message
          end
        end
      end

      # Let the user know the results
      if count > 0
        msg = "#{count} assets have been updated using policy #{@policy}."
        notify_user(:notice, msg)
        # Add a row into the activity table
        ActivityLog.create({:organization_id => @policy.organization.id, :user_id => current_user.id, :item_type => "Policy Asset Update", :activity => msg, :activity_time => Time.current})
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
    params.require(:policy_asset_subtype_rule).permit(policy_asset_subtype_rule_allowable_params)
  end

  def asset_type_rule_form_params
    params.require(:policy_asset_type_rule).permit(policy_asset_type_rule_allowable_params)
  end

  def get_policy
    @policy = Policy.find_by(:object_key => params[:id]) unless params[:id].nil?
    if @policy.nil?
      redirect_to '/404'
      return
    end

  end

end
