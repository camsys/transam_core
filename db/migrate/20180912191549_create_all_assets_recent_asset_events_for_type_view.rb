class CreateAllAssetsRecentAssetEventsForTypeView < ActiveRecord::Migration[5.2]
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW all_assets_recent_asset_events_for_type_view AS
      SELECT
        aet.id AS asset_event_type_id, aet.name AS asset_event_name, Max(ae.created_at) AS asset_event_created_time, ae.transam_asset_id, Max(ae.id) AS asset_event_id
      FROM asset_events AS ae
      LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
      LEFT JOIN transam_assets AS ta  ON ta.id = ae.transam_asset_id
      WHERE aet.id IN ( 1, 2, 6, 8, 10, 19, 21)
      GROUP BY aet.id, ae.transam_asset_id;
    )
  end

  def down
    DROP VIEW if exists most_recent_asset_event_view;
    self.connection.execute "DROP VIEW if exists all_assets_recent_asset_events_for_type_view;"
  end
end
