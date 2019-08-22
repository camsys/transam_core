class AddUpdaterAssetEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_events, :updated_by, after: :created_by_id
  end
end
