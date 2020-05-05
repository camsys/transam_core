class AddActionNameToSystemConfigFieldCustomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :system_config_field_customizations, :action_name, :string
  end
end
