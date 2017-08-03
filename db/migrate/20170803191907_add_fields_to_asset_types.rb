class AddFieldsToAssetTypes < ActiveRecord::Migration
  def change
    add_column :asset_types, :allow_parent, :boolean, after: :description

    AssetType.update_all(allow_parent: false)
    AssetType.where(class_name: ['Equipment', 'Expenditure', 'Component']).update_all(allow_parent: true)
  end
end
