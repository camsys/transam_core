# Inventory searcher. 
# Designed to be populated from a search form using a new/create controller model.
#
class OrganizationSearcher < BaseSearcher

  # From the application config    
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name   
  MAX_ROWS_RETURNED         = SystemConfig.instance.max_rows_returned

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

  # Performs the query by assembling the conditions from the set of conditions below.
  def perform_query
    # Create a class instance of the asset type which can be used to perform
    # active record queries
    Rails.logger.info conditions
    Organization.where(conditions).limit(MAX_ROWS_RETURNED)  
  end

  def organization_type_conditions
    ["organizations.organization_type_id = ?", organization_type_id] unless organization_type_id.blank?
  end
  
  def keyword_conditions
    ["organizations.name LIKE ?", "%#{keywords}%"] unless keywords.blank?
  end
  
  def minimum_price_conditions
    #["products.price >= ?", minimum_price] unless minimum_price.blank?
  end
  
  def maximum_price_conditions
    #["products.price <= ?", maximum_price] unless maximum_price.blank?
  end
  
  def category_conditions
    #["products.category_id = ?", category_id] unless category_id.blank?
  end
  
end
