class AddCommentModel < ActiveRecord::Migration
  def change
    
    # Comments table
    create_table :comments do |t|
      t.string    :object_key,        :limit => 12,   :null => :false
      t.integer   :commentable_id,                    :null => :false
      t.string    :commentable_type,                  :null => :false
      t.text      :comment,                           :null => :false
      t.integer   :created_by_id,                     :null => :false      
      t.timestamps
    end

    add_index :comments, [:commentable_id, :commentable_type], :name => "comments_idx1"
    
  end
end
