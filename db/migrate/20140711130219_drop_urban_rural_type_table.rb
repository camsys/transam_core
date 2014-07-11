class DropUrbanRuralTypeTable < ActiveRecord::Migration
  def change

    # Drop tables no longer needed
    drop_table :urban_rural_types

  end
end
