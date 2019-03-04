class CreateQueryAssetClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :query_asset_classes do |t|
      t.string :table_name
      t.string :transam_assets_join
      t.timestamps
    end
  end
end
