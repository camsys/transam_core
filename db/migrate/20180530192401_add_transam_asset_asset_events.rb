class AddTransamAssetAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :transam_asset_id, :integer, after: :asset_id
  end
end
