class FixFullTextSearchIndices < ActiveRecord::Migration

  def up
    change_table :keyword_search_indices do |t|
      t.string :name, :limit => 254, :null => false
      t.remove :object_key
      t.string :object_key ,:limit => 12 ,:null => :false
      t.remove :object_class
      t.string :object_class ,:limit => 50 ,:null => :false
      t.remove :context
      t.string :context ,:limit => 50 ,:null => :true
      t.remove :summary
      t.text :summary	,:limit => 50 ,:null => :true
      t.remove :search_text 
      t.text :search_text ,:limit => 2147483647 ,:null => :false
    end
  end
  
  def down
    change_table :keyword_search_indices do |t|
      t.remove :name
    end
  end

end
