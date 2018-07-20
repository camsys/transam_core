class AddConfigExtensionsSystemConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :new_user_service, :string, after: :default_fiscal_year_formatter
    add_column :system_configs, :user_role_service, :string, after: :new_user_service
    add_column :system_configs, :policy_analyzer, :string, after: :user_role_service
    add_column :system_configs, :default_weather_code, :string, after: :policy_analyzer
  end
end
