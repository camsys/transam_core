module TablePreferences

  DEFAULT_TABLE_PREFERENCES = 
    {
      bus: { 
          sort: [{org_name: :ascending}, {asset_id: :ascending}],
          columns: [:asset_id, :org_name, :vin, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      rail_car: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :vin, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      ferry: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :vin, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      other_passenger_vehicle: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :vin, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      service_vehicle: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :vin, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      capital_equipment: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :description, :manufacturer, :model, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      admin_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :facility_name, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      maintenance_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :facility_name, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      passenger_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :facility_name, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      parking_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :facility_name, :year, :type, :subtype, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      track: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :from_line, :from_segment, :to_line, :to_segment, :subtype, :description, :main_line,  :branch, :track, :segment_type, :location, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      guideway: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :from_line, :from_segment, :to_line, :to_segment, :subtype, :description, :main_line,  :branch, :number_of_tracks, :segment_type, :location, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      power_signal: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}],
        columns: [:asset_id, :org_name, :from_line, :from_segment, :to_line, :to_segment, :subtype, :description, :main_line,  :branch, :segment_type, :location, :service_status, :last_life_cycle_action, :life_cycle_action_date]
      },
      groups: {
        sort: [{name: :ascending}],
      },
      disposition: {
        sort: [{org_name: :ascending}]
      },
      transfer: {
        sort: [{org_name: :ascending}]
      },
      saved_queries: {
        sort: [{name: :ascending}]
      },
      bulk_updates: {
        sort: [{uploaded_at: :descending}]
      },
      projects: {
        sort: [{fiscal_year: :ascending}, {org_name: :ascending},  {project_id: :ascending}]
      },
      project_phase: {
        sort: [{fiscal_year: :ascending}, {org_name: :ascending},  {project_id: :ascending}]
      },
      programs: {
        sort: [{name: :ascending}]
      },
      templates: {
        sort: [{name: :ascending}]
      },
      buckets: {
        sort: [{fiscal_year: :ascending}, {name: :ascending}, {owner: :ascending}]
      },
      grants: {
        sort: [{owner: :ascending}, {year: :descending}]
      },
      bond_requests: {
        sort: [{org_name: :ascending}, {created: :descending}]
      },
      import_export: {
        sort: [{created_at: :descending}, {type: :ascending}]
      },
      my_funds: {
        sort: [{fiscal_year: :ascending}, {name: :ascending}, {owner: :ascending}]
      },
      status: {sort: []},
      audit: {
        sort: [{org_name: :ascending}, {audit_type: :ascending}, {asset_id: :ascending}]
      },
      user_login_report: {sort: []},
      issues_report: {sort: []},
      performance_restrictions: {
        sort: [{active_start: :descending}]
      },
      asset_condition_report: [],
      asset_age_report: [],
      asset_funding_source_report: [],
      unconstrainted_capital_projects_report_summary: [],
      unconstrained_capital_preojects_report_by_org: [],
      needs_versus_funding_statewide_report: [],
      ali_funding_report: [],
      ali_funding_report_ali_specific_drilldown: [],
      capital_plan_report: [],
      bond_request_report: [],
      quarterly_reports: {
        sort: [{fy_q: :descending}, {operator: :ascending}]
      },
      opt5b_reports: {
        sort: [{fy_q: :descending}, {operator: :ascending}]
      },
      ntd_revenue_vehicles: {
        sort: [{org_name: :ascending}, {year_manufactured: :descending}]
      },
      ntd_service_vehicles: {
        sort: [{org_name: :ascending}, {year_manufactured: :descending}]
      },
      ntd_manage_fleets: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}]
      },
      ntd_asset_reports: {
        sort: [{org_name: :ascending}, {ntd_reporting_year: :descending}]
      },
      tam_service_life_summary_report_vehicles: [],
      tam_service_life_summary_report_facilities: [],
      tam_service_life_summary_report_track: [],
      map_overlay_service: {
        sort: [{name: :ascending}]
      },
      message_templates: {
        sort: [{id: :ascending}]
      },
      message_history: {
        sort: [{entry_date_and_time: :descending}]
      },
      audits: {
        sort: [{name: :ascending}, {description: :ascending}, {last_run: :descending}]
      },
      org_names: {
        sort: [{short_name: :ascending}]
      },
      users: {
        sort: [{last_name: :ascending}, {organization: :ascending}]
      },
      activity_log: {
        sort: [{date_time: :descending}]
      },
      notices: {
        sort: [{visible: :ascending}, {display_until: :descending}]
      },
      online_users: {
        sort: [{user: :ascending}]
      }
    }

  # Get all table preferences, or preferences for a specific table
  def table_preferences table_code=nil
    if table_code
      prefs = eval(table_prefs || "{}").try(:[], table_code.to_sym)
      if prefs.nil? 
        return DEFAULT_TABLE_PREFERENCES[table_code.to_sym]
      else
        # We have preferences, make sure that every type of preference is filled out
        if prefs[:sort].nil?
          prefs[:sort] = DEFAULT_TABLE_PREFERENCES[table_code.to_sym].try(:[], :sort)
        elsif prefs[:columns].nil? 
          prefs[:columns] = DEFAULT_TABLE_PREFERENCES[table_code.to_sym].try(:[], :columns)
        end
        return prefs 
      end
    else
      table_prefs
    end
  end

  # Get column preferences for a specific table
  def column_preferences table_code
      preferences = table_preferences table_code
      preferences.try(:[], :columns) || DEFAULT_TABLE_PREFERENCES[table_code.to_sym][:columns]
  end

  # Used to generate a SQL string for sorting on the preferred column
  #TODO: Move to TableTools
  def table_sort_string table_code
    sorting = table_preferences(table_code)[:sort]
    column = sorting.first 
    key = column.keys.first 
    order_string = (column[key] == :descending) ? "DESC" : "ASC"
    fallback_key =  DEFAULT_TABLE_PREFERENCES[table_code.to_sym][:sort].first.keys[0]
    sort_column = SORT_COLUMN[table_code][key] || SORT_COLUMN[table_code][fallback_key]
    return "#{sort_column} #{order_string}"
  end

  # Update a user's sort and preferred columns for a table 
  def update_table_prefs table_code, sort_column, sort_order, columns_string=nil 
    # Get the user's current set of preferences for all tables.
    all_table_prefs = eval(self.table_preferences.to_s) || {}
    this_table_prefs = all_table_prefs[table_code.to_sym] || {}

    # Update the sort order
    if sort_column
      sort_params = {}
      asc_desc = (sort_order.to_s.downcase == "descending") ? :descending : :ascending
      sort_params[sort_column.to_sym] = asc_desc 
      sort_params = [sort_params]
      this_table_prefs[:sort] =  sort_params
    end 

    # Update the selected columns
    if columns_string
      columns = columns_string.split(',').map{ |x| x.downcase.strip.to_sym}
      this_table_prefs[:columns] =  columns
    end
    all_table_prefs[table_code.to_sym] = this_table_prefs
    self.update(table_prefs: all_table_prefs)
  end

  # This is done as a reset
  def delete_table_prefs table_code 
    table_prefs = eval(self.table_preferences || "{}")
    table_prefs.delete(table_code.to_sym)
    self.update(table_prefs: table_prefs)
  end

  private 

  #TODO: Move to TableTools
  # THis is a map between every column and the SQL string required to sort on that column
  SORT_COLUMN = {
    track: 
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'transam_assets.description',
        from_line: 'infrastructures.from_line',
        to_line: 'infrastructures.to_line',
        from_segment: 'infrastructures.from_segment',
        to_segment: 'infrastructures.to_segment',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        track: 'infrastructure_tracks.name',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name',
        fta_asset_class: 'fta_asset_classes.name',
        type: 'fta_track_types.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    guideway: 
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'transam_assets.description',
        from_line: 'infrastructures.from_line',
        to_line: 'infrastructures.to_line',
        from_segment: 'infrastructures.from_segment',
        to_segment: 'infrastructures.to_segment',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        number_of_tracks: 'num_tracks',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name',
        fta_asset_class: 'fta_asset_classes.name',
        type: 'fta_guideway_types.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    power_signal:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'transam_assets.description',
        from_line: 'infrastructures.from_line',
        to_line: 'infrastructures.to_line',
        from_segment: 'infrastructures.from_segment',
        to_segment: 'infrastructures.to_segment',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name',
        fta_asset_class: 'fta_asset_classes.name',
        type: 'fta_power_signal_types.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    capital_equipment:
      { 
        asset_id: 'transam_assets.asset_tag',
        org_name: 'organizations.name',
        description: 'transam_assets.description',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'transam_assets.manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        quantity: 'transam_assets.quantity',
        quantity_unit: 'transam_assets.quantity_unit',
        purchase_cost: 'transam_assets.purchase_cost',
        in_service_date: 'transam_assets.in_service_date',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'transam_assets.policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'transam_assets.scheduled_replacement_year',
        scheduled_replacement_cost: 'transam_assets.scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    service_vehicle:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'manufacture_year',
        type: 'fta_vehicle_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        chassis: 'chasses.name',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        license_plate: 'license_plate',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        mileage: 'mileage_events.current_mileage',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    bus:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'manufacture_year',
        type: 'fta_vehicle_types.name',
        subtype: 'asset_subtypes.name',
        external_id: 'transam_assets.external_id',
        license_plate: 'license_plate',
        fta_asset_class: 'fta_asset_classes.name',
        vehicle_length: 'vehicle_length',
        vehicle_length_unit: 'vehicle_length_unit',
        purchase_cost: 'purchase_cost',
        esl_category: 'esl_categories.name',
        chassis: 'chasses.name',
        fuel_type: 'fuel_types.name',
        direct_capital_responsibility: 'pcnt_capital_responsibility',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        in_service_date: 'in_service_date',
        operator: 'operators.short_name',
        seating_capacity: 'seating_capacity',
        fta_funding_type: 'fta_funding_types.name',
        fta_ownership_type: 'fta_ownership_types.name',
        mileage: 'mileage_events.current_mileage',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    rail_car: { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'manufacture_year',
        type: 'fta_vehicle_types.name',
        subtype: 'asset_subtypes.name',
        external_id: 'transam_assets.external_id',
        license_plate: 'license_plate',
        fta_asset_class: 'fta_asset_classes.name',
        vehicle_length: 'vehicle_length',
        vehicle_length_unit: 'vehicle_length_unit',
        purchase_cost: 'purchase_cost',
        esl_category: 'esl_categories.name',
        chassis: 'chasses.name',
        fuel_type: 'fuel_types.name',
        direct_capital_responsibility: 'pcnt_capital_responsibility',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        in_service_date: 'in_service_date',
        operator: 'operators.short_name',
        seating_capacity: 'seating_capacity',
        fta_funding_type: 'fta_funding_types.name',
        fta_ownership_type: 'fta_ownership_types.name',
        mileage: 'mileage_events.current_mileage',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    ferry: { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'manufacture_year',
        type: 'fta_vehicle_types.name',
        subtype: 'asset_subtypes.name',
        external_id: 'transam_assets.external_id',
        license_plate: 'license_plate',
        fta_asset_class: 'fta_asset_classes.name',
        vehicle_length: 'vehicle_length',
        vehicle_length_unit: 'vehicle_length_unit',
        purchase_cost: 'purchase_cost',
        esl_category: 'esl_categories.name',
        chassis: 'chasses.name',
        fuel_type: 'fuel_types.name',
        direct_capital_responsibility: 'pcnt_capital_responsibility',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        in_service_date: 'in_service_date',
        operator: 'operators.short_name',
        seating_capacity: 'seating_capacity',
        fta_funding_type: 'fta_funding_types.name',
        fta_ownership_type: 'fta_ownership_types.name',
        mileage: 'mileage_events.current_mileage',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    other_passenger_vehicle: 
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'transam_assets_model_names.combined_name',
        year: 'manufacture_year',
        type: 'fta_vehicle_types.name',
        subtype: 'asset_subtypes.name',
        external_id: 'transam_assets.external_id',
        license_plate: 'license_plate',
        fta_asset_class: 'fta_asset_classes.name',
        vehicle_length: 'vehicle_length',
        vehicle_length_unit: 'vehicle_length_unit',
        purchase_cost: 'purchase_cost',
        esl_category: 'esl_categories.name',
        chassis: 'chasses.name',
        fuel_type: 'fuel_types.name',
        direct_capital_responsibility: 'pcnt_capital_responsibility',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        in_service_date: 'in_service_date',
        operator: 'operators.short_name',
        seating_capacity: 'seating_capacity',
        fta_funding_type: 'fta_funding_types.name',
        fta_ownership_type: 'fta_ownership_types.name',
        mileage: 'mileage_events.current_mileage',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    passenger_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        description: 'transam_assets.description',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    admin_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        description: 'transam_assets.description',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    parking_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        description: 'transam_assets.description',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    maintenance_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name',
        fta_asset_class: 'fta_asset_classes.name',
        external_id: 'transam_assets.external_id',
        purchase_cost: 'purchase_cost',
        in_service_date: 'in_service_date',
        description: 'transam_assets.description',
        pcnt_capital_responsibility: 'pcnt_capital_responsibility',
        term_condition: 'condition_events.assessed_rating',
        term_rating: 'condition_events.condition_type_id IS NULL, condition_types.name',
        service_status: 'service_status_types.name',
        last_life_cycle_action: 'asset_event_types.name',
        life_cycle_action_date: 'all_events.event_date',
        policy_replacement_year_as_fiscal_year: 'policy_replacement_year',
        scheduled_replacement_year_as_fiscal_year: 'scheduled_replacement_year',
        scheduled_replacement_cost: 'scheduled_replacement_cost',
        rebuild_rehab_description: 'rebuild_rehab_events.comments',
        rebuild_rehab_date: 'rebuild_rehab_events.event_date'
      },
    users:
      { 
        last_name: "last_name",
        first_name: "first_name",
        organization: "organizations.short_name",
        email: "email",
        phone: "phone",
        phone_ext: "phone_ext",
        title: "title",
        status: "active",
        external_id: "external_id",
        system_access: "active",
        timezone: "timezone",
        notify_via_email: "notify_via_email",
        num_table_rows: "num_table_rows",
        sign_in_count: "sign_in_count",
        last_sign_in_at: "last_sign_in_at",
        last_sign_in_ip: "last_sign_in_ip",
        failed_attempts: "failed_attempts",
        locked_at: "locked_at",
        created_at: "created_at",
        updated_at: "updated_at"
      },
    projects:
      { 
        project_number: "project_number",
        organization: "organizations.short_name",
        fiscal_year: "fy_year",
        title: "title",
        project_type: "capital_project_types.name",
        sogr: "sogr",
        shadow: "notional:",
        multi_year: "multi_year",
        emergency: "emergency"
      }
  }

end
