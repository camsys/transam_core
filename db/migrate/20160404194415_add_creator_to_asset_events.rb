class AddCreatorToAssetEvents < ActiveRecord::Migration
  def change
    add_column :asset_events, :created_by_id, :integer
    add_index :asset_events, :created_by_id, :name => "asset_events_creator_idx"
  end

end
