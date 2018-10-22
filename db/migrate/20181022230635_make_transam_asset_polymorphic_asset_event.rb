class MakeTransamAssetPolymorphicAssetEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :asset_events, :transam_asset_type, :string, after: :asset_id
  end
end
