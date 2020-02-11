class RunQueryToolMostRecentAssetEventsScriptOnCore < ActiveRecord::Migration[5.2]
  def change
    most_recent_view_sql = <<-SQL
      CREATE OR REPLACE VIEW query_tool_most_recent_asset_events_for_type_view AS
        SELECT
          aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time,
          ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
        FROM asset_events AS ae
        LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
        LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
        GROUP BY aet.id, ae.base_transam_asset_id;
    SQL
    ActiveRecord::Base.connection.execute most_recent_view_sql
  end
end
