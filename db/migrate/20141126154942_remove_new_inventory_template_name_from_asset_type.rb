class RemoveNewInventoryTemplateNameFromAssetType < ActiveRecord::Migration
  def change
    remove_column :asset_types, :new_inventory_template_name, :string
  end
end
