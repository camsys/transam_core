class AddDependentOccupantTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :transam_assets, :parent_id, :integer, after: :other_lienholder
    add_column :transam_assets, :location_id, :integer, after: :parent_id
  end
end
