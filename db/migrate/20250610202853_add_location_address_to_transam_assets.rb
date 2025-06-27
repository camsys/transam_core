class AddLocationAddressToTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :transam_assets, :location_address, :string
  end
end
