class ChangeLocationToParent < ActiveRecord::Migration
  def change
    rename_column :assets, :location_id, :parent_id
  end
end
