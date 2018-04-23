class PoliciesController < OrganizationAwareController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Policies", :rule_sets_path

  skip_before_action :get_organization_selections
  before_action :set_viewable_organizations

  #before_filter :authorize_admin
  before_action :get_policy, :except => [:index, :create, :new]

  # Lock down the controller
  authorize_resource only: [:index, :show, :create, :edit, :update, :destroy]


  SESSION_VIEW_TYPE_VAR = 'policies_subnav_view_type'

  def get_subtype_minimum_value

    valid = true

    if @policy.parent.present?
      rule = @policy.parent.policy_asset_subtype_rules.find_by(asset_subtype_id: params[:asset_subtype_id].to_i)

      min = 0
      if rule.present?
        params[:policy_asset_subtype_rule].each do |key, val|
          min = rule.send(key)
          valid = (min <= val.to_i)
        end
      end
    end

    results = (valid ? valid : "Please enter a value greater than or equal to #{min}.").to_json
    respond_to do |format|
     format.json { render :json =>  results}
    end
  end

  def check_subtype_rule_exists
    valid = @policy.policy_asset_subtype_rules.find_by(asset_subtype_id: params[:asset_subtype_id].to_i, fuel_type_id: params[:fuel_type_id]).present?

    respond_to do |format|
      format.json { render :json =>  valid}
    end
  end

  def index
    if params[:organization_id]
      org_id = params[:organization_id]
    else
      org_id = @organization_list.first
    end

    if params[:policy_id]
      policy = Policy.find_by(id: params[:policy_id], organization_id: org_id)
    else
      policy = Policy.active.find_by(organization_id: org_id)
    end

    redirect_to policy_path(policy)
  end

  def show

    add_breadcrumb "Asset Replacement/Rehabilitation Policy", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)

  end

  def new
    #right now, no blank policies can be created - just copying existing policies
  end

  #-----------------------------------------------------------------------------
  # Loads an edit form for a policy. called via ajax
  #-----------------------------------------------------------------------------
  def show_edit_form

    @notice = params[:notice] if params[:notice]

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

      if @copy || !(@rule.subtype_fuel_type_rule_used? (@policy.parent.present? ? [@policy.organization_id] : ([@policy.organization_id] + Policy.where(parent_id: @policy.id).pluck(:organization_id))))
        @valid_fuel_types = FuelType.active.where.not(id: @policy.policy_asset_subtype_rules.where('id != ? AND asset_subtype_id = ?', @rule.id, @rule.asset_subtype_id).pluck(:fuel_type_id))

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

    try_create_replace_with_rule rule

  end

  #-----------------------------------------------------------------------------
  # Removes a policy rule from the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def remove_policy_rule

    rule = @policy.policy_asset_subtype_rules.find(params[:rule])
    if rule.nil?
      notify_user_immediately "Can't find the rule in policy #{@policy}", "warning"
    elsif Asset.where(organization_id: @policy.organization_id, asset_subtype_id: rule.asset_subtype_id, fuel_type_id: rule.fuel_type_id).count > 0
      notify_user_immediately "Can't remove a default rule being used from #{@policy}", "warning"
    else
      if rule.try(:parent_rule_can_destroy?)
        AssetSubtype.find_by(id: rule.asset_subtype_id).destroy
      end
      rule.destroy

      notify_user_immediately "Rule was successfully removed from #{@policy}"
    end

    render 'update_policy_rules'

  end

  #-----------------------------------------------------------------------------
  # Adds a policy rule to the current policy. Called via ajax
  #-----------------------------------------------------------------------------
  def add_policy_rule

    if params[:policy_asset_type_rule].present?
      rule = PolicyAssetTypeRule.new(asset_type_rule_form_params)

      if rule.asset_type.nil?
        # for now default most fields
        new_type = AssetType.create(
          name: params[:new_asset_type_name],
          description: params[:new_asset_type_description],
          class_name: 'Component',
          display_icon_name: 'fa fa-cogs',
          map_icon_name: 'blueIcon',
          active: true
        )
        rule.asset_type = new_type
      end
    else
      if params[:copied_rule].present? # if the rule is copied, copy from old rule and overwrite with form
        rule = PolicyAssetSubtypeRule.find(params[:copied_rule]).dup
        rule.assign_attributes(asset_subtype_rule_form_params)
      else
        rule = PolicyAssetSubtypeRule.new(asset_subtype_rule_form_params)
      end

      # if creating a new asset subtype and policy rule
      if rule.asset_subtype.nil?
        new_subtype = AssetSubtype.create(
            asset_type_id: params[:new_asset_subtype_asset_type_id],
            name: params[:new_asset_subtype_name],
            description: params[:new_asset_subtype_description],
            active: true
        )
        rule.asset_subtype = new_subtype
      end
    end



    if rule.present?
      rule.policy = @policy
      rule.save
    end

    try_create_replace_with_rule rule



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

      @valid_fuel_types = FuelType.active
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

    add_breadcrumb "Asset Replacement/Rehabilitation Policy", policies_path
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

    new_policy.save
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

    add_breadcrumb "Asset Replacement/Rehabilitation Policy", policies_path
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
    add_breadcrumb "Asset Replacement/Rehabilitation Policy", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "Policy Runner", runner_policy_path(@policy)

    @builder_proxy = AssetUpdaterProxy.new(:policy => @policy)
    @asset_types = AssetType.active.where(id: @policy.organization.asset_type_counts.keys)
    @message = "Applying policy to selected assets. This may take a while..."
  end

  def update_assets

    @builder_proxy = AssetUpdaterProxy.new(params[:asset_updater_proxy])
    if @builder_proxy.valid?

      Delayed::Job.enqueue AssetUpdateAllJob.new(@policy.organization, @builder_proxy.asset_types, current_user), :priority => 0

      # Let the user know the results
      msg = "Assets are being updated using policy #{@policy}. You will be notified when the process is complete."
      notify_user(:notice, msg)

      redirect_to policy_path @policy
      return
    else
      respond_to do |format|
        format.html { render :action => "updater" }
      end
    end

  end

  def inherit
    add_breadcrumb "Asset Replacement/Rehabilitation Policy", policies_path
    add_breadcrumb @policy.name, policy_path(@policy)
    add_breadcrumb "Distribute Policy", inherit_policy_path(@policy)

    @distributer_proxy = PolicyDistributerProxy.new(:policy => @policy)
    @message = "Distributing and applying policies. This may take a while..."
  end

  def distribute
    @distributer_proxy = PolicyDistributerProxy.new(params[:policy_distributer_proxy])
    @distributer_proxy.policy = @policy

    policies = Policy.where(parent_id: @distributer_proxy.policy.id)
    if policies.empty?
      notify_user(:alert, 'No children policies to distribute policy rules too.')
    else
      Delayed::Job.enqueue PolicyDistributerJob.new(@distributer_proxy, current_user), :priority => 0

      notify_user(:notice, 'Parent policy distributed. Values updated to at least the minimum allowed by the parent policy.')
    end

    redirect_to policy_path(@policy)
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

  def try_create_replace_with_rule rule
    if (rule.try(:replace_asset_subtype_id) || rule.try(:replace_fuel_type_id))
      if @policy.policy_asset_subtype_rules.find_by(asset_subtype_id: (rule.replace_asset_subtype_id || rule.asset_subtype_id), fuel_type_id: (rule.replace_fuel_type_id || rule.fuel_type_id)).nil?
        policy_to_use = @policy.parent.present? ? @policy.parent : @policy
        new_rule = policy_to_use.policy_asset_subtype_rules.find_by(asset_subtype_id: (rule.replace_asset_subtype_id || rule.asset_subtype_id)).dup
        new_rule.policy = @policy # reset duplicated rule to agency's policy
        new_rule.fuel_type_id = (rule.replace_fuel_type_id || rule.fuel_type_id)
        if new_rule.save
          if params[:edit_rule_after]
            redirect_to show_edit_form_policy_path(@policy, :rule => new_rule.id, :type => 'asset_subtype', :notice => 'Please edit the policy rule corresponding to your Replace With assets.'), format: 'js'
            return
          end
        end

      end
    end

    render 'update_policy_rules'
  end

  def get_policy
    @policy = Policy.find_by(:object_key => params[:id], :organization_id => (@organization_list + (defined?(Grantor).present? ? Grantor.ids : [])).uniq) unless params[:id].nil?
    if @policy.nil?
      if Policy.find_by(:object_key => params[:id], :organization_id => current_user.user_organization_filters.system_filters.first.get_organizations.map{|x| x.id}).nil?
        redirect_to '/404'
      else
        notify_user(:warning, 'This record is outside your filter. Change your filter if you want to access it.')
        redirect_to policies_path
      end
      return
    end

  end

  def set_viewable_organizations
    @viewable_organizations = current_user.viewable_organization_ids

    get_organization_selections
  end

end
