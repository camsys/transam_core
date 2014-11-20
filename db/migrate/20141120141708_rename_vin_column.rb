class RenameVinColumn < ActiveRecord::Migration
  def change
    rename_column :assets, :vin, :serial_number
  end
end
