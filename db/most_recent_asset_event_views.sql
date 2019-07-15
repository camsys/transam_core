DROP VIEW if exists recent_asset_events_views;
CREATE OR REPLACE VIEW recent_asset_events_views AS
      SELECT aet.id AS asset_event_type_id, aet.class_name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time, ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
      FROM asset_events AS ae
      LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
      LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
      GROUP BY aet.id, ae.base_transam_asset_id;

DROP VIEW if exists all_assets_most_recent_asset_event_view;
CREATE OR REPLACE VIEW all_assets_most_recent_asset_event_view AS
      SELECT
        ae.base_transam_asset_id, Max(ae.created_at) AS asset_event_created_time,  Max(ae.id) AS asset_event_id
      FROM asset_events AS ae
      LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
      LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
      GROUP BY ae.base_transam_asset_id;