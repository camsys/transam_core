class CreateDualFuelTypes < ActiveRecord::Migration
  def change
    create_table :dual_fuel_types do |t|
      t.integer :primary_fuel_type_id, index: true
      t.integer :secondary_fuel_type_id, index: true
      t.boolean :active
    end

    add_column :assets, :dual_fuel_type_id, :integer
  end
end
