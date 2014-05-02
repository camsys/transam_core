class AddFyYearStartToSysConfig < ActiveRecord::Migration
  def change
    add_column  :system_configs, :start_of_fiscal_year,  :string, :limit => 5, :after => :customer_id
  end
end
