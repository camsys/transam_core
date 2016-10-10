#
# Abstract controller that is used as the base class
# for any concrete controllers that are based on an organization
#
class OrganizationAwareController < TransamController

  # set the @organization and @organization_list variables before any actions are invoked
  before_filter :get_organization_selections

  # always use typed organizations for this controller
  RENDER_TYPED_ORGANIZATIONS = true

  USER_SELECTED_ORGANIZATION          = "user_selected_org_session_var"
  USER_SELECTED_ORGANIZATION_ID_LIST  = "user_selected_org_id_list_session_var"

  protected

  # Sets the @organization and @organization_list class variables.
  def get_organization_selections

    if current_user
      # Check to see if the session org variable was set. If it is then we use the
      # selected org
      if session[USER_SELECTED_ORGANIZATION].nil?
        org = current_user.organization
      else
        # not session variable so get the user's default organizations
        org = Organization.find_by_short_name(session[USER_SELECTED_ORGANIZATION])
      end

      if render_typed_organizations
        @organization = get_typed_organization(org)
      else
        @organization = org
      end

      # Set the organization list variable.

      # Check to see if it is set, This should be set as the session is created
      # but just in case...
      if session[USER_SELECTED_ORGANIZATION_ID_LIST].nil?
        @organization_list = []
        session[USER_SELECTED_ORGANIZATION_ID_LIST] = @organization_list
      end

      @organization_list = session[USER_SELECTED_ORGANIZATION_ID_LIST]
      # Make sure the list is not empty. If it is, set it to the list of organizations
      # for the current user
      if @organization_list.empty?
        @organization_list = current_user.organization_ids
      end

    else
      notify_user(:alert, 'Record not found!')
      redirect_to(organizations_url)
      return
    end

  end

  def render_typed_organizations
    RENDER_TYPED_ORGANIZATIONS
  end

  # Store the list of organizations in the user's session
  def set_selected_organization_list(orgs)
    list = []
    orgs.each do |o|
      list << o.id
    end
    session[OrganizationAwareController::USER_SELECTED_ORGANIZATION_ID_LIST] = list
  end


  # Set the session varibale with the newly selected organization
  def set_selected_organization(org)
    session[USER_SELECTED_ORGANIZATION] = org.short_name
  end


  def set_current_user_organization_filter_(user, filter)
    Rails.logger.debug "Setting agency filter to: #{filter}"

    # Set the session variable to store the list of organizations for reporting
    if filter.query_string.present?
      organizations =  TransitOperator.find_by_sql(filter.query_string)
    else
      organizations = filter.organizations
    end
    set_selected_organization_list(organizations)

    # Save the selection. Next time the user logs in the filter will be reset
    user.user_organization_filter = filter
    user.save

    # Set the filter name in the session
    session[:user_organization_filter] = filter.name
  end

  def get_typed_organization(org)

    class_name = org.organization_type.class_name
    klass = Object.const_get class_name
    o = klass.find(org.id)
    # puts o.inspect
    return o
  end
end
