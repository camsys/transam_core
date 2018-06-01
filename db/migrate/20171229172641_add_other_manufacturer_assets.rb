class AddOtherManufacturerAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :assets, :other_manufacturer, :string, after: :manufacturer_id
  end
end
