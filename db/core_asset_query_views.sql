-- Full list of database views to serve as data source for Query Tool
-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------
DROP VIEW if exists parent_transam_assets_view;
CREATE OR REPLACE VIEW parent_transam_assets_view AS
SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
CONCAT(asset_tag, IF(description IS NOT NULL, ' : ', ''), IFNULL(description,'')) AS parent_name
FROM `transam_assets`
WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL)

-- postgis
-- CREATE OR REPLACE VIEW parent_transam_assets_view AS
--   SELECT transam_assets.organization_id, transam_assets.id AS parent_id, transam_assets.asset_tag, transam_assets.description,
--   CONCAT(asset_tag, CASE WHEN description IS NOT NULL THEN ' : ' ELSE '' END, description) AS parent_name
--   FROM transam_assets
--   WHERE transam_assets.id IN (SELECT DISTINCT parent_id FROM transam_assets WHERE parent_id IS NOT NULL) OR transam_assets.id IN (SELECT DISTINCT location_id FROM transam_assets WHERE location_id IS NOT NULL)