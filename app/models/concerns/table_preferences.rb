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
      eval(table_prefs || "{}").try(:[], table_code.to_sym) || DEFAULT_TABLE_PREFERENCES[table_code.to_sym]
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
    return "#{SORT_COLUMN[table_code][key]} #{order_string}"
  end

  # Update a user's sort and preferred columns for a table 
  def update_table_prefs table_code, sort_column, sort_order, columns_string 
    # Get the user's current set of preferences for all tables.
    table_prefs = eval(self.table_preferences || "{}")
    
    # Update the sort order
    if sort_column
      sort_params = {}
      asc_desc = (sort_order.to_s.downcase == "descending") ? :descending : :ascending
      sort_params[sort_column.to_sym] = asc_desc 
      sort_params = [sort_params]
      table_prefs[table_code.to_sym][:sort] = sort_params
    end 

    # Update the selected columns
    if columns_string
      columns = columns_string.split(',').map{ |x| x.downcase.strip.to_sym}
      table_prefs[table_code.to_sym][:columns] = columns
    end

    self.update(table_prefs: table_prefs)
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
        description: 'description',
        from_line: 'from_line',
        to_line: 'to_line',
        from_segment: 'from_segment',
        to_segment: 'to_segment',
        location: 'relative_location',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        track: 'infrastructure_tracks.name',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name'
      },
    guideway: 
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'description',
        from_line: 'from_line',
        to_line: 'to_line',
        from_segment: 'from_segment',
        to_segment: 'to_segment',
        location: 'relative_location',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        number_of_tracks: 'num_tracks',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name'
      },
    power_signal:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'description',
        from_line: 'from_line',
        to_line: 'to_line',
        from_segment: 'from_segment',
        to_segment: 'to_segment',
        location: 'relative_location',
        subtype: 'asset_subtypes.name',
        main_line: 'infrastructure_divisions.name',
        branch: 'infrastructure_subdivisions.name',
        location: 'relative_locations.name',
        segment_type: 'infrastructure_segment_types.name'
      },
    capital_equipment:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        description: 'description',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    service_vehicle:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    bus:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    rail_car: { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    ferry: { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    other_passenger_vehicle: 
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        vin: 'serial_number',
        manufacturer: 'manufacturers.name',
        model: 'manufacturer_models.name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    passenger_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    admin_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    parking_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    maintenance_facility:
      { 
        asset_id: 'asset_tag',
        org_name: 'organizations.name',
        facility_name: 'facility_name',
        year: 'manufacture_year',
        type: 'fta_equipment_types.name',
        subtype: 'asset_subtypes.name'
      },
    users:
      { 
        last_name: "last_name",
        first_name: "first_name",
        organization: "organizations.short_name",
        email: "email",
        phone: "phone",
        phone_ext: "phone_ext",
        title: "title"
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