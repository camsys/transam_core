class CreateSystemConfigExtensions < ActiveRecord::Migration[5.2]
  def change
    create_table :system_config_extensions do |t|
      t.string :class_name
      t.string :extension_name
      t.boolean :active

      t.timestamps
    end
  end
end
