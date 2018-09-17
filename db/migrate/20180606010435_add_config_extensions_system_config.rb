class AddConfigExtensionsSystemConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :default_weather_code, :string, after: :default_fiscal_year_formatter
  end
end
