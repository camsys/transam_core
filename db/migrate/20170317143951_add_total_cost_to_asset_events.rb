class AddTotalCostToAssetEvents < ActiveRecord::Migration
  def change
    add_column :asset_events, :total_cost, :integer, before: :comments
  end
end
