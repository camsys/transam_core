class AddDefaultFiscalYearFormatter < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :default_fiscal_year_formatter, :string, after: :start_of_fiscal_year
  end
end
