class CreateAllAssetsMostRecentAssetEventView < ActiveRecord::Migration[5.2]
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW all_assets_most_recent_asset_event_view AS
      SELECT
        ae.transam_asset_id, Max(ae.created_at) AS asset_event_created_time,  Max(ae.id) AS asset_event_id
      FROM asset_events AS ae
      LEFT JOIN asset_event_types AS aet ON aet.id = ae.asset_event_type_id
      LEFT JOIN transam_assets AS ta  ON ta.id = ae.transam_asset_id
      GROUP BY ae.transam_asset_id;
    )
  end

  def down
    self.connection.execute "DROP VIEW if exists all_assets_most_recent_asset_event_view;"
  end
end
