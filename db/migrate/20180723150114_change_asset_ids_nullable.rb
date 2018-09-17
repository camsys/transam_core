class ChangeAssetIdsNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :asset_events, :asset_id, :integer, null: true
    change_column :asset_groups_assets, :asset_id, :integer, null: true
  end
end
