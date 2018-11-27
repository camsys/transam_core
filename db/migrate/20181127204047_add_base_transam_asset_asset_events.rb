class AddBaseTransamAssetAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_events, :base_transam_asset, after: :transam_asset_id
  end
end
