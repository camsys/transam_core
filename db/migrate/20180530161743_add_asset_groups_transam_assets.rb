class AddAssetGroupsTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_groups_assets, :transam_asset, after: :asset_id


  end
end
