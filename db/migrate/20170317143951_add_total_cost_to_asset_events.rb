class AddTotalCostToAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :total_cost, :integer, before: :comments
  end
end
