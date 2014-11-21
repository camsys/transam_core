# Convert from storing service life metrics by year to storing them by month.
# Any existing data should be edited in place
class ConvertServiceLifeToMonths < ActiveRecord::Migration
  def up
    rename_column :policy_items, :max_service_life_years, :max_service_life_months
    rename_column :policy_items, :extended_service_life_years, :extended_service_life_months
    execute "update policy_items set max_service_life_months = 12 * max_service_life_months"
    execute "update policy_items set extended_service_life_months = 12 * extended_service_life_months"
  end

  def down
    rename_column :policy_items, :max_service_life_months, :max_service_life_years
    rename_column :policy_items, :extended_service_life_months, :extended_service_life_years
    execute "update policy_items set max_service_life_years = 12 / max_service_life_years"
    execute "update policy_items set extended_service_life_years = 12 / extended_service_life_years"
  end
end
