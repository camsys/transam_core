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

  def render_typed_organizations
    RENDER_TYPED_ORGANIZATIONS
  end

  # Store the list of organizations in the user's session
  def set_selected_organization_list(orgs)
    list = []
    orgs.each do |o|
      list << o.id
    end
    session[USER_SELECTED_ORGANIZATION_ID_LIST] = org.short_name
  end
  
  # Set the session varibale with the newly selected organization
  def set_selected_organization(org)
    session[USER_SELECTED_ORGANIZATION] = org.short_name
  end

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
      
      # Set the organization list variable. This will be set only if the user has access
      # to other organizations for reporting
      if session[USER_SELECTED_ORGANIZATION_ID_LIST].nil?
        @organization_list = [current_user.organization.id]
      else
        # not session variable so get the user's default organizations
        @organization_list = session[USER_SELECTED_ORGANIZATION_ID_LIST]
      end
      
    else
      notify_user(:alert, 'Record not found!')
      redirect_to(organizations_url)
      return
    end
    
  end
        
  def get_typed_organization(org)
    
    class_name = org.organization_type.class_name
    klass = Object.const_get class_name
    o = klass.find(org.id)
    # puts o.inspect
    return o
  end
end
