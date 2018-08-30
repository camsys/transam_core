class RemoveRecentAssetEventsViews < ActiveRecord::Migration[5.2]
  def up
    self.connection.execute %Q(
      DROP VIEW if exists recent_asset_events_views;
    )
  end

  def down
    self.connection.execute "DROP VIEW if exists recent_asset_events_views;"
  end
end
