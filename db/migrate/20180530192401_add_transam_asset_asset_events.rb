class AddTransamAssetAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_events, :transam_asset, after: :asset_id
  end
end
