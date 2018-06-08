class AddPrimaryKeyAssetGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_groups_assets, :id, :primary_key, first: true
  end
end
