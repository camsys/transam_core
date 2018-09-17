class RemoveAssetBaseClassNameSystemConfig < ActiveRecord::Migration[5.2]
  def change
    remove_column :system_configs, :asset_base_class_name
  end
end
