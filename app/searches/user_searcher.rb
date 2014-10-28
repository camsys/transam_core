# Inventory searcher. 
# Designed to be populated from a search form using a new/create controller model.
#
class UserSearcher < BaseSearcher # TODO Not Implemented.  Just copied from other models

  # From the application config    
  MAX_ROWS_RETURNED         = SystemConfig.instance.max_rows_returned

  # add any search params to this list
  attr_accessor :organization_id,
                :keywords

  # Return the name of the form to display
  def form_view
    'user_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'user_search_results_table'
  end

  def cache_variable_name
    UsersController::INDEX_KEY_LIST_VAR
  end
               
  def initialize(attributes = {})
    super(attributes)
  end    
  
  private

  # Add any new conditions here. The property name must end with _conditions
  def organization_conditions
    if organization_id.blank?
      ["assets.organization_id in (?)", get_id_list(user.organizations)]
    else
      ["assets.organization_id = ?", organization_id]
    end
  end
  #---------------------------------------------------
  # FTA Reporting Characteristics
  #---------------------------------------------------
  def fta_funding_type_conditions
    ["assets.fta_funding_type_id = ?", fta_funding_type_id] unless fta_funding_type_id.blank?
  end
  def fta_ownership_type_conditions
    ["assets.fta_ownership_type_id = ?", fta_ownership_type_id] unless fta_ownership_type_id.blank?
  end
  def fta_vehicle_type_id_conditions
    ["assets.fta_vehicle_type_id = ?", fta_vehicle_type_id] unless fta_vehicle_type_id.blank?
  end

  #---------------------------------------------------
  # Asset Properties
  #---------------------------------------------------

  def manufacturer_conditions
    ["assets.manufacturer_id = ?", manufacturer_id] unless manufacturer_id.blank?
  end
  
  def manufacturer_model_conditions
    ["assets.manufacturer_model LIKE ?", "%#{manufacturer_model}%"] unless manufacturer_model.blank?
  end
  
  def district_type_conditions
    ["assets.district_type_id = ?", district_id] unless district_id.blank?
  end

  def asset_type_conditions
    ["assets.asset_type_id = ?", asset_type_id] unless asset_type_id.blank?
  end
    
  def asset_subtype_conditions
    ["assets.asset_subtype_id = ?", asset_subtype_id] unless asset_subtype_id.blank?
  end
  
  def asset_tag_conditions
    ["assets.asset_tag LIKE ?", "%#{asset_tag}%"] unless asset_tag.blank?
  end

  #---------------------------------------------------
  # Asset Condition
  #---------------------------------------------------
  def asset_condition_type_conditions
    ["assets.reported_condition_type_id = ?", condition_type_id] unless condition_type_id.blank?
  end
    
  def asset_replacement_year_conditions
    ["assets.estimated_replacement_year = ?", replacement_year] unless replacement_year.blank?
  end
  
  def keyword_conditions
    #["products.name LIKE ?", "%#{keywords}%"] unless keywords.blank?
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
