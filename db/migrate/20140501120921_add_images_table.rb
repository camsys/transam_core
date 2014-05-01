class AddImagesTable < ActiveRecord::Migration
  def change
    # Images table
    create_table :images do |t|
      t.string    :object_key,        :limit => 12,   :null => :false
      t.integer   :imagable_id,                       :null => :false
      t.string    :imagable_type,                     :null => :false
      t.string    :image,             :limit => 128,  :null => :false
      t.string    :description
      t.string    :original_filename, :limit => 128,  :null => :false
      t.string    :content_type,      :limit => 128,  :null => :false
      t.integer   :file_size
      t.integer   :created_by_id,                     :null => :false      
      t.timestamps
    end
    add_index :images, [:object_key], :name => "images_idx1"
    add_index :images, [:imagable_id, :imagable_type], :name => "images_idx2"
  end
end
