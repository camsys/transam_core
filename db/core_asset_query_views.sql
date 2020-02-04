-- Full list of database views to serve as data source for Query Tool
-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------
DROP VIEW if exists parent_transam_assets_view;
CREATE OR REPLACE VIEW parent_transam_assets_view AS
SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), IFNULL(description,'')) AS parent_name
FROM `transam_assets`
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL)

DROP VIEW if exists query_tool_most_recent_asset_events_for_type_view;
CREATE OR REPLACE VIEW query_tool_most_recent_asset_events_for_type_view AS
SELECT
    aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time,
    ae.base_transam_asset_id, Max(ae.id) AS asset_event_id
FROM asset_events AS ae
LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
LEFT JOIN transam_assets AS ta  ON ta.id = ae.base_transam_asset_id
GROUP BY aet.id, ae.base_transam_asset_id;

-- postgis
-- CREATE OR REPLACE VIEW parent_transam_assets_view AS
--   SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
--   CONCAT(asset_tag, CASE WHEN description IS NOT NULL THEN ' : ' ELSE '' END, description) AS parent_name
--   FROM transam_assets
--   WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL) OR transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)