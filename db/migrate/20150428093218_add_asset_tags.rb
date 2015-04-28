class AddAssetTags < ActiveRecord::Migration
  def change
    create_table :asset_tags do |t|
      t.integer     :asset_id,  :null => :false
      t.integer     :user_id,   :null => :false
    end

    add_index :asset_tags,   :asset_id,   :name => :asset_tags_idx1
    add_index :asset_tags,   :user_id,    :name => :asset_tags_idx2
  end
end
