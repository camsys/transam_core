class MoveAssetGroupsTransamAssets < ActiveRecord::DataMigration
  def up
    Asset.joins(:asset_groups).each do |asset|
      asset.transit_asset.asset_groups = asset.asset_groups
    end
  end
end