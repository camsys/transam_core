# 
# Abstract controller that is used as the base class
# for any concrete controllers that are based on an organization
#
class OrganizationAwareController < TransamController
  # set the @organization variable before any actions are invoked
  before_filter :get_organization
         
  # always use typed organizations for this controller
  RENDER_TYPED_ORGANIZATIONS = true
          
  protected

  def render_typed_organizations
    RENDER_TYPED_ORGANIZATIONS
  end

  # Sets the @organization class variable. 
  def get_organization

    if current_user
      org = current_user.organization
      if render_typed_organizations
        @organization = get_typed_organization(org)
      else
        @organization = org
      end
    else
        redirect_to(organizations_url, :flash => { :alert => 'Record not found!'})
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
