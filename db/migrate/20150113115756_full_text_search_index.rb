class FullTextSearchIndex < ActiveRecord::Migration
  def change
    create_table :keyword_search_indices do |t|
      t.string :object_class,   :limit => 64,   :null => :false,   :after => :id
      t.string :object_key,     :limit => 12,   :null => :false,   :after => :object_class
      t.string :context,        :limit => 64,   :null => :true,    :after => :object_key
      t.string :summary,        :limit => 64,   :null => :true,    :after => :context
      t.text   :search_text,    :limit => 1024, :null => :false,   :after => :summary
      t.timestamps
    end

    add_index :keyword_search_indices, [:object_class], :name => :keyword_search_indices_idx1
  end
end
