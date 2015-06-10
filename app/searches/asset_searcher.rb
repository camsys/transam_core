# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class AssetSearcher < BaseSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  # From the application config
  ASSET_BASE_CLASS_NAME     = SystemConfig.instance.asset_base_class_name

  # add any search params to this list.  Grouped based on their logical queries
  attr_accessor :organization_ids,
                :organization_id,
                :district_id,
                :asset_type_ids,
                :asset_subtype_ids,
                :manufacturer_ids,
                :parent_id,
                :disposition_date,
                :keyword,
                :estimated_condition_type_ids,
                :vendor_ids,
                :service_status_type_ids,
                :manufacturer_model,
                # Comparator-based (<=>)
                :manufacture_year,
                :manufacture_year_comparator,
                :purchase_cost,
                :purchase_cost_comparator,
                :replacement_year,
                :replacement_year_comparator,
                :scheduled_replacement_year,
                :scheduled_replacement_year_comparator,
                :policy_replacement_year,
                :policy_replacement_year_comparator,
                :purchase_date,
                :purchase_date_comparator,
                :manufacture_date,
                :manufacture_date_comparator,
                :in_service_date,
                :in_service_date_comparator,
                # Checkboxes
                :in_backlog,
                :purchased_new



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

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def estimated_condition_type_conditions
    clean_estimated_condition_type_ids = remove_blanks(estimated_condition_type_ids)
    @klass.where(estimated_condition_type_id: estimated_condition_type_ids) unless clean_estimated_condition_type_ids.empty?
  end

  def manufacturer_conditions
    clean_manufacturer_ids = remove_blanks(manufacturer_ids)
    @klass.where(manufacturer_id: clean_manufacturer_ids) unless clean_manufacturer_ids.empty?
  end

  def district_type_conditions
    @klass.where(district_id: district_id) unless district_id.blank?
  end

  def asset_type_conditions
    clean_asset_type_ids = remove_blanks(asset_type_ids)
    @klass.where(asset_type_id: clean_asset_type_ids) unless clean_asset_type_ids.empty?
  end

  def asset_subtype_conditions
    clean_asset_subtype_ids = remove_blanks(asset_subtype_ids)
    @klass.where(asset_subtype_id: clean_asset_subtype_ids) unless clean_asset_subtype_ids.empty?
  end

  def location_id_conditions
    @klass.where(parent_id: parent_id) unless parent_id.blank?
  end

  def vendor_conditions
    clean_vendor_ids = remove_blanks(vendor_ids)
    @klass.where(vendor_id: clean_vendor_ids) unless clean_vendor_ids.empty?
  end

  def service_status_type_conditions
    clean_service_status_type_ids = remove_blanks(service_status_type_ids)
    @klass.where(service_status_type: service_status_type_ids) unless clean_service_status_type_ids.empty?
  end

  #---------------------------------------------------
  # Comparator Queries
  #---------------------------------------------------
  def manufacture_year_conditions
    unless manufacture_year.blank?
      case manufacture_year_comparator
      when "-1" # Before Year X
        @klass.where("manufacture_year < ?", manufacture_year)
      when "0" # During Year X
        @klass.where("manufacture_year = ?", manufacture_year)
      when "1" # After Year X
        @klass.where("manufacture_year > ?", manufacture_year)
      end
    end
  end

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

  # Special handling because this is a Date column in the DB, not an integer
  def in_service_date_conditions
    unless in_service_date.blank?
      case in_service_date_comparator
      when "-1" # Before Year X
        @klass.where("in_service_date < ?", in_service_date)
      when "0" # During Year X
        @klass.where("in_service_date = ?", in_service_date)
      when "1" # After Year X
        @klass.where("in_service_date > ?", in_service_date)
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

  #---------------------------------------------------
  # Custom Queries # When the logic does not fall into the above categories, place the method here
  #---------------------------------------------------

  def organization_conditions
    if organization_id.blank?
      if organization_ids.empty?
        @klass.where(organization_id: get_id_list(user.organizations))
      else
        @klass.where(organization_id: organization_ids)
      end
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

  def manufacturer_model_conditions
    unless manufacturer_model.blank?
      manufacturer_model.strip!
      wildcard_search = "%#{manufacturer_model}%"
      @klass.where("manufacturer_model LIKE ?", wildcard_search)
    end
  end

  # Equality check but requires type conversion and bounds checking
  def disposition_date_conditions
    unless disposition_date.blank?
      disposition_date_as_date = Date.new(disposition_date.to_i)
      @klass.where("disposition_date >= ? and disposition_date <= ?", disposition_date_as_date, disposition_date_as_date.end_of_year)
    end
  end

  # Special handling because this is a Date column in the DB, not an integer
  def purchase_date_conditions
    unless purchase_date.blank?
      case purchase_date_comparator
      when "-1" # Before Year X
        @klass.where("purchase_date < ?", purchase_date)
      when "0" # During Year X
        @klass.where("purchase_date = ?", purchase_date)
      when "1" # After Year X
        @klass.where("purchase_date > ?", purchase_date)
      end
    end
  end

  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
