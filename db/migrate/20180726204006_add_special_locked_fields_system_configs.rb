class AddSpecialLockedFieldsSystemConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :special_locked_fields, :string, after: :data_file_path
  end
end
