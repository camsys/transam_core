class AddIsVisibleAndLabelToSystemConfigFieldCustomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :system_config_field_customizations, :is_visible, :boolean
    add_column :system_config_field_customizations, :label, :string
  end
end
