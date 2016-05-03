class AddNewOrganizationIdToAssetEvents < ActiveRecord::Migration
  def change
    add_column :asset_events, :organization_id, :int, after: :comments
  end
end
