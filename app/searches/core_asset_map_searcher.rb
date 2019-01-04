# Inventory searcher.
# Designed to be populated from a search form using a new/create controller model.
#
class CoreAssetMapSearcher

  # Include the numeric sanitizers mixin
  include TransamNumericSanitizers

  # add any search params to this list.  Grouped based on their logical queries
  def self.form_params
    [ :organization_id,
      :asset_type_id,
      :asset_subtype_id,
      :manufacturer_id,
      :location_id,
      :keyword,
      :estimated_condition_type_id,
      :reported_condition_type_id,
      :vendor_id,
      :service_status_type_id,
      :manufacturer_model,
      :equipment_description,
      :asset_scope,
      # Comparator-based (<=>)
      :disposition_date,
      :disposition_date_comparator,
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
      :equipment_quantity,
      :equipment_quantity_comparator,
      # Checkboxes
      :in_backlog,
      :purchased_new,
      :early_replacement,
      :disposed_early
    ]
  end

  private

  #---------------------------------------------------
  # Simple Equality Queries
  #---------------------------------------------------

  def estimated_condition_type_conditions
    clean_estimated_condition_type_id = remove_blanks(estimated_condition_type_id)
    @klass.where(estimated_condition_type_id: clean_estimated_condition_type_id) unless clean_estimated_condition_type_id.empty?
  end

  def reported_condition_type_conditions
    clean_reported_condition_type_id = remove_blanks(reported_condition_type_id)
    @klass.where(reported_condition_type_id: clean_reported_condition_type_id) unless clean_reported_condition_type_id.empty?
  end

  def manufacturer_conditions
    clean_manufacturer_id = remove_blanks(manufacturer_id)
    @klass.where(manufacturer_id: clean_manufacturer_id) unless clean_manufacturer_id.empty?
  end

  def location_id_conditions
    @klass.where(location_id: location_id) unless location_id.blank?
  end

  def vendor_conditions
    clean_vendor_id = remove_blanks(vendor_id)
    @klass.where(vendor_id: clean_vendor_id) unless clean_vendor_id.empty?
  end

  def service_status_type_conditions
    clean_service_status_type_id = remove_blanks(service_status_type_id)
    @klass.where(service_status_type: clean_service_status_type_id) unless clean_service_status_type_id.empty?
  end


  def asset_scope_conditions
    unless asset_scope.blank?
      case asset_scope
      when "Disposed"
        @klass.disposed
      when "Operational"
        @klass.operational
      when "In Service"
        @klass.in_service
      end
    else
      @klass.where('asset_tag != object_key') # ignore assets in pending early replacement cycle
    end
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
      purchase_cost_as_int = sanitize_to_int(purchase_cost)
      case purchase_cost_comparator
      when "-1" # Less than X miles
        @klass.where("purchase_cost < ?", purchase_cost_as_int)
      when "0" # Exactly X miles
        @klass.where("purchase_cost = ?", purchase_cost_as_int)
      when "1" # Greater than X miles
        @klass.where("purchase_cost > ?", purchase_cost_as_int)
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

  def early_replacement_conditions
    @klass.early_replacement unless early_replacement.to_i.eql? 0
  end

  def disposed_early_conditions
    unless disposed_early.to_i.eql? 0
      yday_of_start_fy = Date.strptime(Date.today.year.to_s+'-'+SystemConfig.instance.start_of_fiscal_year, '%Y-%m-%d').yday
      @klass.where('(IF(disposition_date < MAKEDATE(YEAR(disposition_date), ?), YEAR(disposition_date)-1,YEAR(disposition_date))) < policy_replacement_year', yday_of_start_fy)
    end
  end

  #---------------------------------------------------
  # Custom Queries # When the logic does not fall into the above categories, place the method here
  #---------------------------------------------------

  def organization_conditions
    # This method works with both individual inputs for organization_id as well
    # as arrays containing several organization ids.

    clean_organization_id = remove_blanks(organization_id)
    @klass.where(organization_id: clean_organization_id)
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
      case disposition_date_comparator
      when "-1" # Before Year X
        @klass.where("disposition_date < ?", disposition_date)
      when "0" # During Year X
        @klass.where("disposition_date = ?", disposition_date)
      when "1" # After Year X
        @klass.where("disposition_date > ?", disposition_date)
      end
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


  #---------------------------------------------------
  # Equipment Queries
  #---------------------------------------------------

  def equipment_description_conditions
    unless equipment_description.blank?
      equipment_description.strip!
      wildcard_search = "%#{equipment_description}%"
      @klass.where("assets.description LIKE ?", wildcard_search)
    end
  end

  def equipment_quantity_conditions
    unless equipment_quantity.blank?
      case equipment_quantity_comparator
      when "-1" # Less than X
        @klass.where("quantity < ?", equipment_quantity)
      when "0" # Equal to X
        @klass.where("quantity = ?", equipment_quantity)
      when "1" # Greater Than X
        @klass.where("quantity > ?", equipment_quantity)
      end
    end
  end

  def asset_type_conditions
    clean_asset_type_id = remove_blanks(asset_type_id)
    @klass.where(asset_type_id: clean_asset_type_id) unless clean_asset_type_id.empty?
  end

  def asset_subtype_conditions
    clean_asset_subtype_id = remove_blanks(asset_subtype_id)
    @klass.where(asset_subtype_id: clean_asset_subtype_id) unless clean_asset_subtype_id.empty?
  end


  # Removes empty spaces from multi-select forms

  def remove_blanks(input)
    output = (input.is_a?(Array) ? input : [input])
    output.select { |e| !e.blank? }
  end

end
