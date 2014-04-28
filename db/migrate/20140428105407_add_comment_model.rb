class AddCommentModel < ActiveRecord::Migration
  def change
    
    # Comments table
    create_table :comments do |t|
      t.integer   :commentable_id
      t.string    :commentable_type
      t.text      :comment,                           :null => :false
      t.integer   :created_by_id,                     :null => :false      
      t.timestamps
    end

    add_index :comments, [:commentable_id, :commentable_type], :name => "comments_idx1"
    
  end
end
