class AddNewOrganizationIdToAssetEvents < ActiveRecord::Migration
  def change
    unless column_exists? :asset_events, :organization_id
      add_column :asset_events, :organization_id, :int, after: :comments
    end
  end
end
