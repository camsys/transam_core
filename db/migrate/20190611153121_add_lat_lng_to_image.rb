class AddLatLngToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :latitude, :float
    add_column :images, :longitude, :float
    add_column :images, :bearing, :float
  end
end
