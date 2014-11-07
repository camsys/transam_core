class AddExternalIdToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :external_id, :string, :limit => 32, :default => nil, :after => :asset_tag
  end
end
