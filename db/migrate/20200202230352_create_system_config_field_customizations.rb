class CreateSystemConfigFieldCustomizations < ActiveRecord::Migration[5.2]
  def change
    create_table :system_config_field_customizations do |t|
      t.string :table_name
      t.string :field_name
      t.string :description
      t.string :code_frag
      t.boolean :is_locked
      t.boolean :active

      t.timestamps
    end

    remove_column :system_configs, :special_locked_fields
  end
end
