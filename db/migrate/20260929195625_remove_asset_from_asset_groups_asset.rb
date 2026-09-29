class RemoveAssetFromAssetGroupsAsset < ActiveRecord::Migration[5.2]
  def change
    remove_column :asset_groups_assets, :asset_id
  end
end
