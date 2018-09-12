class RemoveMostRecentAssetEventView < ActiveRecord::Migration[5.2]
  def up
    self.connection.execute %Q(
      DROP VIEW if exists most_recent_asset_event_view;
    )
  end

  def down
    self.connection.execute "DROP VIEW if exists most_recent_asset_event_view;"
  end
end
