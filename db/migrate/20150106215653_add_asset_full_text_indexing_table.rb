class AddAssetFullTextIndexingTable < ActiveRecord::Migration
  
  def up
    create_table :asset_indexes do |t|
      
      t.string     :object_key,            :limit => 12, :null => :false
      t.text :search_text
      t.timestamps
    end
  end

  def down
  	drop_table :asset_indexes
  end

end
