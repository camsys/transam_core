class AddFyYearSystemConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :fy_year, :integer, after: :start_of_fiscal_year
  end
end
