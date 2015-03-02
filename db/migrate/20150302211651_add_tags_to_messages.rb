class AddTagsToMessages < ActiveRecord::Migration
  def change
    create_table :message_tags do |t|
      t.integer     :message_id,      :null => :false
      t.integer     :user_id,         :null => :false
    end

    add_index :message_tags,   :message_id,   :name => :message_tags_idx1
    add_index :message_tags,   :user_id,      :name => :message_tags_idx2
  end
end
