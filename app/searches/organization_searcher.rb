# Inventory searcher. 
# Designed to be populated from a search form using a new/create controller model.
#
class OrganizationSearcher < BaseSearcher

  # From the application config    
  ASSET_BASE_CLASS_NAME     = Rails.application.config.asset_base_class_name

  # add any search params to this list
  attr_accessor :district_id,
                :organization_type_id,
                :keywords


  # Return the name of the form to display
  def form_view
    'organization_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'organization_search_results_table'
  end
              
  def cache_variable_name
    OrganizationsController::INDEX_KEY_LIST_VAR
  end
               
  def initialize(attributes = {})
    super(attributes)
  end    

  private

  def organization_type_conditions
    unless organization_type_id.blank?
      Organization.where(organization_type_id: organization_type_id)
    else
      Organization.where(id:  user.user_organization_filter.get_organizations.map{|o| o.id})
    end
  end
  
  def keyword_conditions
    Organization.where("organizations.name LIKE ?", "%#{keywords}%") unless keywords.blank?
  end  
end
