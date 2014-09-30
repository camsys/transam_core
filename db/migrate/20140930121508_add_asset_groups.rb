class AddAssetGroups < ActiveRecord::Migration
  def change
    create_table :asset_groups do |t|
      t.string    :object_key,      :limit => 12, :null => :false
      t.integer   :organization_id,               :null => :false
      t.string    :name,            :limit => 64, :null => :false
      t.text      :description,                   :null => :false
      t.boolean   :active
      t.timestamps
    end
    
    create_join_table :assets, :asset_groups
    
    add_index :asset_groups, :object_key,       :unique => :true, :name => :asset_groups_idx1
    add_index :asset_groups, :organization_id,                    :name => :asset_groups_idx2
        
  end
end
