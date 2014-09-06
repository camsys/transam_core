# Inventory searcher. 
# Designed to be populated from a search form using a new/create controller model.
#
class AssetSearcher < BaseSearcher
  include NumericSanitizers

  # From the application config    
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name   

  # add any search params to this list.  Grouped based on their logical queries
  attr_accessor :organization_id,
                :district_id,
                :asset_type_id, 
                :asset_subtype_id, 
                :manufacturer_id,
                :location_id,
                :disposition_date,
                :keyword,
                :fta_funding_type_id,
                :fta_funding_source_type_id,
                :fta_ownership_type_id,
                :fta_vehicle_type_id,
                :condition_type_ids,
                # Comparator-based (<=>)
                :purchase_cost,
                :purchase_cost_comparator,
                :estimated_value,
                :estimated_value_comparator,
                :replacement_year,
                :replacement_year_comparator,
                :scheduled_replacement_year,
                :scheduled_replacement_year_comparator,
                :policy_replacement_year,
                :policy_replacement_year_comparator,
                :purchase_date,
                :purchase_date_comparator,
                :reported_mileage,
                :reported_mileage_comparator,
                :manufacture_date,
                :manufacture_date_comparator,
                # Checkboxes
                :in_backlog,
                :purchased_new,
                :ada_accessible_lift,
                :ada_accessible_ramp,
                :fta_emergency_contingency_fleet

  
  # Return the name of the form to display
  def form_view
    'asset_search_form'
  end
  # Return the name of the results table to display
  def results_view
    'asset_search_results_table'
  end
               
  def initialize(attributes = {})
    @klass = Object.const_get ASSET_BASE_CLASS_NAME  
    super(attributes)
  end    

  def to_s
    queries.to_sql
  end

  def cache_variable_name
    AssetsController::INDEX_KEY_LIST_VAR
  end
  
  protected
  # Performs the query by assembling the conditions from the set of conditions below.
  def perform_query
    # Create a class instance of the asset type which can be used to perform
    # active record queries
    Rails.logger.info queries.to_sql
    queries.limit(MAX_ROWS_RETURNED)  
  end

  # Take a series of methods which return AR queries and reduce them down to a single LARGE query
  def queries
    condition_parts.reduce(:merge)
  end

  def condition_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end


  private


  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def asset_condition_type_conditions
    @klass.where(reported_condition_type_id: condition_type_ids) unless condition_type_ids.blank?
  end

  def fta_funding_type_conditions
    @klass.where(fta_funding_type_id: fta_funding_type_id) unless fta_funding_type_id.blank?
  end

  def fta_funding_source_type_conditions
    @klass.where(fta_funding_source_type_id: fta_funding_source_type_id) unless fta_funding_source_type_id.blank?
  end

  def fta_ownership_type_conditions
    @klass.where(fta_ownership_type_id: fta_ownership_type_id) unless fta_ownership_type_id.blank?
  end

  def fta_vehicle_type_id_conditions
    @klass.where(fta_vehicle_type_id: fta_vehicle_type_id) unless fta_vehicle_type_id.blank?
  end

  def manufacturer_conditions
    @klass.where(manufacturer_id: manufacturer_id) unless manufacturer_id.blank?
  end
  
  def district_type_conditions
    @klass.where(district_id: district_id) unless district_id.blank?
  end

  def asset_type_conditions
    @klass.where(asset_type_id: asset_type_id) unless asset_type_id.blank?
  end
    
  def asset_subtype_conditions
    @klass.where(asset_subtype_id: asset_subtype_id) unless asset_subtype_id.blank?
  end

  def location_id_conditions
    @klass.where(location_id: location_id) unless location_id.blank?
  end

  #---------------------------------------------------
  # Comparator Queries
  #---------------------------------------------------
  def scheduled_replacement_year_conditions
    unless scheduled_replacement_year.blank?
      case scheduled_replacement_year_comparator
      when "-1" # Before Year X
        @klass.where("scheduled_replacement_year < ?", scheduled_replacement_year) 
      when "0" # During Year X
        @klass.where("scheduled_replacement_year = ?", scheduled_replacement_year) 
      when "1" # After Year X
        @klass.where("scheduled_replacement_year > ?", scheduled_replacement_year) 
      end
    end
  end

  def policy_replacement_year_conditions
    unless policy_replacement_year.blank?
      case policy_replacement_year_comparator
      when "-1" # Before Year X
        @klass.where("policy_replacement_year < ?", policy_replacement_year) 
      when "0" # During Year X
        @klass.where("policy_replacement_year = ?", policy_replacement_year) 
      when "1" # After Year X
        @klass.where("policy_replacement_year > ?", policy_replacement_year) 
      end
    end
  end

  # Special handling because this is a Date column in the DB, not an integer
  def purchase_date_conditions
    unless purchase_date.blank?
      year_as_integer = purchase_date.to_i
      purchase_date = Date.new(year_as_integer)
      case purchase_date_comparator
      when "-1" # Before Year X
        @klass.where("purchase_date < ?", purchase_date )
      when "0" # During Year X
        @klass.where("purchase_date >= ? AND purchase_date <= ?", purchase_date, purchase_date.end_of_year) 
      when "1" # After Year X
        @klass.where("purchase_date > ?", purchase_date.end_of_year) 
      end
    end
  end

  def reported_mileage_conditions
    unless reported_mileage.blank?
      reported_mileage_as_int = sanitize_to_int(reported_mileage)
      case reported_mileage_comparator
      when "-1" # Less than X miles
        @klass.where("reported_mileage < ?", reported_mileage_as_int) 
      when "0" # Exactly X miles
        @klass.where("reported_mileage = ?", reported_mileage_as_int) 
      when "1" # Greater than X miles
        @klass.where("reported_mileage > ?", reported_mileage_as_int) 
      end
    end
  end

  def estimated_value_conditions
    unless estimated_value.blank?
      value_as_int = sanitize_to_int(estimated_value)
      case estimated_value_comparator
      when "-1" # Less than X miles
        @klass.where("estimated_value < ?", value_as_int) 
      when "0" # Exactly X miles
        @klass.where("estimated_value = ?", value_as_int) 
      when "1" # Greater than X miles
        @klass.where("estimated_value > ?", value_as_int) 
      end
    end
  end

  def purchase_cost_conditions
    unless purchase_cost.blank?
      purchase_cost_as_float = sanitize_to_float(purchase_cost)
      case purchase_cost_comparator
      when "-1" # Less than X miles
        @klass.where("purchase_cost < ?", purchase_cost) 
      when "0" # Exactly X miles
        @klass.where("purchase_cost = ?", purchase_cost) 
      when "1" # Greater than X miles
        @klass.where("purchase_cost > ?", purchase_cost) 
      end
    end
  end

  #---------------------------------------------------
  # Checkbox Queries # Not checking a box is different than saying "restrict to things where this is false"
  #---------------------------------------------------

  def in_backlog_conditions
    @klass.where(in_backlog: true) unless in_backlog.to_i.eql? 0
  end

  def purchased_new_conditions
    @klass.where(purchased_new: true) unless purchased_new.to_i.eql? 0
  end

  def ada_accessible_lift_conditions
    @klass.where(ada_accessible_lift: true) unless ada_accessible_lift.to_i.eql? 0
  end

  def ada_accessible_ramp_conditions
    @klass.where(ada_accessible_ramp: true) unless ada_accessible_ramp.to_i.eql? 0
  end

  def fta_emergency_contingency_fleet_conditions
    @klass.where(fta_emergency_contingency_fleet: true) unless fta_emergency_contingency_fleet.to_i.eql? 0
  end

  #---------------------------------------------------
  # Custom Queries # When the logic does not fall into the above categories, place the method here
  #---------------------------------------------------
    
  def organization_conditions
    if organization_id.blank?
      @klass.where(organization_id: get_id_list(user.organizations))
    else
      @klass.where(organization_id: organization_id)
    end
  end

  def keyword_conditions # TODO break apart by commas
    unless keyword.blank?
      searchable_columns = ["assets.manufacturer_model", "assets.description", "assets.asset_tag", "organizations.name", "organizations.short_name"] # add any freetext-searchable fields here
      keyword.strip!
      search_str = searchable_columns.map { |x| "#{x} like :keyword"}.to_sentence(:words_connector => " OR ", :last_word_connector => " OR ")
      @klass.joins(:organization).where(search_str, :keyword => "%#{keyword}%")
    end
  end

  # Equality check but requires type conversion and bounds checking
  def disposition_date_conditions
    unless disposition_date.blank?
      disposition_date_as_date = Date.new(disposition_date.to_i)
      @klass.where("disposition_date >= ? and disposition_date <= ?", disposition_date_as_date, disposition_date_as_date.end_of_year)
    end
  end
end
