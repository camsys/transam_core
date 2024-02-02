class DropInfrastructureAssetTableViewsIfEmpty < ActiveRecord::Migration[5.2]
  def up
    if connection.table_exists?(:infrastructure_asset_table_views) &&
       connection.execute("select exists(select 1 from infrastructure_asset_table_views)")
      drop_table :infrastructure_asset_table_views
    end
  end

  def down
    # Not needed
  end
end
