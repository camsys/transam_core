class ChangeQueryAssetClassFieldType < ActiveRecord::Migration[5.2]
  def change
    change_column :query_asset_classes, :transam_assets_join, :text
  end
end
