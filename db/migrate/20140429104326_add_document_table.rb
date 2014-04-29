class AddDocumentTable < ActiveRecord::Migration
  def change
    
    # Documents table
    create_table :documents do |t|
      t.string    :object_key,        :limit => 12,   :null => :false
      t.integer   :documentable_id,                   :null => :false
      t.string    :documentable_type,                 :null => :false
      t.string    :document,          :limit => 128,  :null => :false
      t.string    :description
      t.string    :original_filename, :limit => 128,  :null => :false
      t.string    :content_type,      :limit => 128,  :null => :false
      t.integer   :file_size
      t.integer   :created_by_id,                     :null => :false      
      t.timestamps
    end
    add_index :documents, [:object_key], :name => "documents_idx1"
    add_index :documents, [:documentable_id, :documentable_type], :name => "documents_idx2"
  end
end
