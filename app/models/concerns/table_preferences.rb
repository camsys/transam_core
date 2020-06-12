module TablePreferences

  DEFAULT_TABLE_PREFERENCES = 
    {
      buses: { 
          sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      rail_cars: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      ferries: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      other_passenger_vehicles: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      service_vehicles: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      capital_equipment: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      admin_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}]
      },
      maintenance_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}]
      },
      passenger_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}]
      },
      parking_facility: {
        sort: [{org_name: :ascending}, {asset_id: :ascending}]
      },
      track: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      guideway: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      power_signal: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      groups: {
        sort: [{name: :ascending}]
      },
      disposition: {
        sort: [{organization: :ascending}]
      },
      transfer: {
        sort: [{organization: :ascending}]
      },
      saved_queries: {
        sort: [{name: :ascending}]
      },
      bulk_updates: {
        sort: [{uploaded_at: :descending}]
      },
      projects: {
        sort: [{year: :ascending}, {organization: :ascending},  {project_id: :ascending}]
      },
      project_phase: {
        sort: [{year: :ascending}, {organization: :ascending},  {project_id: :ascending}]
      },
      programs: {
        sort: [{name: :ascending}]
      },
      templates: {
        sort: [{name: :ascending}]
      },
      buckets: {
        sort: [{year: :ascending}, {name: :ascending}, {owner: :ascending}]
      },
      grants: {
        sort: [{owner: :ascending}, {year: :descending}]
      },
      bond_requests: {
        sort: [{organization: :ascending}, {created: :descending}]
      },
      import_export: {
        sort: [{created_at: :descending}, {type: :ascending}]
      },
      my_funds: {
        sort: [{year: :ascending}, {name: :ascending}, {owner: :ascending}]
      },
      status: {sort: []},
      audit: {
        sort: [{organization: :ascending}, {audit_type: :ascending}, {asset_id: :ascending}]
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
        sort: [{organization: :ascending}, {year_manufactured: :descending}]
      },
      ntd_service_vehicles: {
        sort: [{organization: :ascending}, {year_manufactured: :descending}]
      },
      ntd_manage_fleets: {
        sort: [{organization: :ascending}, {asset_id: :ascending}]
      },
      ntd_asset_reports: {
        sort: [{organization: :ascending}, {ntd_reporting_year: :descending}]
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
      organizations: {
        sort: [{short_name: :ascending}]
      },
      users: {
        sort: [{last: :ascending}, {primary_organization: :ascending}]
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

  def table_preferences table_code=nil
    if table_code
      eval(table_prefs || "{}").try(:[], table_code.to_sym) || DEFAULT_TABLE_PREFERENCES[table_code.to_sym]
    else
      table_prefs
    end
  end

end