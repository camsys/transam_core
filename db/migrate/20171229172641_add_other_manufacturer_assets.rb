class AddOtherManufacturerAssets < ActiveRecord::Migration
  def change
    add_column :assets, :other_manufacturer, :string, after: :manufacturer_id
  end
end
