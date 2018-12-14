class CreateQueryFieldAssetClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :query_field_asset_classes do |t|
      t.references :query_field, foreign_key: true
      t.references :query_asset_class, foreign_key: true

      t.timestamps
    end
  end
end
