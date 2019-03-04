class AddEngineNameSystemConfigExtensions < ActiveRecord::Migration[5.2]
  def change
    add_column :system_config_extensions, :engine_name, :string, after: :extension_name
  end
end
