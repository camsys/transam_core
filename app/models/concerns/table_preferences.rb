module TablePreferences

  DEFAULT_TABLE_PREFERENCES = 
    {
      buses: { 
          sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      rail_cars: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      ferries: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      other_passenger_vehicles: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      service_vehicles: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      capital_equipment: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      administrative: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      maintenance: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      passenger: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      parking: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      track: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      guideway: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      power_signal: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      groups: {
        sort: [{column: :name, order: :ascending}]
      },
      disposition: {
        sort: [{column: :organization, order: :ascending}]
      },
      transfer: {
        sort: [{column: :organization, order: :ascending}]
      },
      saved_queries: {
        sort: [{column: :name, order: :ascending}]
      },
      bulk_updates: {
        sort: [{column: :uploaded_at, order: :descending}]
      },
      projects: {
        sort: [{column: :year, order: :ascending}, {column: :organization, order: :ascending},  {column: :project_id, order: :ascending}]
      },
      project_phase: {
        sort: [{column: :year, order: :ascending}, {column: :organization, order: :ascending},  {column: :project_id, order: :ascending}]
      },
      programs: {
        sort: [{column: :name, order: :ascending}]
      },
      templates: {
        sort: [{column: :name, order: :ascending}]
      },
      buckets: {
        sort: [{column: :year, order: :ascending}, {column: :name, order: :ascending}, {column: :owner, order: :ascending}]
      },
      grants: {
        sort: [{column: :owner, order: :ascending}, {column: :year, order: :descending}]
      },
      bond_requests: {
        sort: [{column: :organization, order: :ascending}, {column: :created, order: :descending}]
      },
      import_export: {
        sort: [{column: :created_at, order: :descending}, {column: :type, order: :ascending}]
      },
      my_funds: {
        sort: [{column: :year, order: :ascending}, {column: :name, order: :ascending}, {column: :owner, order: :ascending}]
      },
      status: {sort: []},
      audit: {
        sort: [{column: :organization, order: :ascending}, {column: :audit_type, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      user_login_report: {sort: []},
      issues_report: {sort: []},
      performance_restrictions: {
        sort: [{column: :active_start, order: :descending}]
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
        sort: [{column: :fy_q, order: :descending}, {column: :operator, order: :ascending}]
      },
      opt5b_reports: {
        sort: [{column: :fy_q, order: :descending}, {column: :operator, order: :ascending}]
      },
      ntd_revenue_vehicles: {
        sort: [{column: :organization, order: :ascending}, {column: :year_manufactured, order: :descending}]
      },
      ntd_service_vehicles: {
        sort: [{column: :organization, order: :ascending}, {column: :year_manufactured, order: :descending}]
      },
      ntd_manage_fleets: {
        sort: [{column: :organization, order: :ascending}, {column: :asset_id, order: :ascending}]
      },
      ntd_asset_reports: {
        sort: [{column: :organization, order: :ascending}, {column: :ntd_reporting_year, order: :descending}]
      },
      tam_service_life_summary_report_vehicles: [],
      tam_service_life_summary_report_facilities: [],
      tam_service_life_summary_report_track: [],
      map_overlay_service: {
        sort: [{column: :name, order: :ascending}]
      },
      message_templates: {
        sort: [{column: :id, order: :ascending}]
      },
      message_history: {
        sort: [{column: :entry_date_and_time, order: :descending}]
      },
      audits: {
        sort: [{column: :name, order: :ascending}, {column: :description, order: :ascending}, {column: :last_run, order: :descending}]
      },
      organizations: {
        sort: [{column: :short_name, order: :ascending}]
      },
      users: {
        sort: [{column: :last, order: :ascending}, {column: :primary_organization, order: :ascending}]
      },
      activity_log: {
        sort: [{column: :date_time, order: :descending}]
      },
      notices: {
        sort: [{column: :visible, order: :ascending}, {column: :display_until, order: :descending}]
      },
      online_users: {
        sort: [{column: :user, order: :ascending}]
      }
    }

  def table_preferences table_code=nil
    if table_code
      eval(table_prefs).try(:[], table_code.to_sym) || DEFAULT_TABLE_PREFERENCES[table_code.to_sym]
    else
      table_prefs
    end
  end

end