class RemoveAddressFieldsFromAssetEvents < ActiveRecord::Migration
  def change
    remove_column :asset_events, :address1, :string, :limit => 128
    remove_column :asset_events, :address2, :string, :limit => 128
    remove_column :asset_events, :city, :string, :limit => 64
    remove_column :asset_events, :state, :string, :limit => 2
    remove_column :asset_events, :zip, :string, :limit => 10
  end
end
