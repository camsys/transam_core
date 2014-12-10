class ChangeLocationToParentInAssetEvent < ActiveRecord::Migration
  def change
    rename_column :asset_events, :location_id, :parent_id
  end
end
