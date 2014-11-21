class AddContactType < ActiveRecord::Migration
  def change
    create_table :contact_types do |t|
      t.string  "name",              :limit => 64,  :null => false
      t.string  "code",              :limit => 3,   :null => false
    end

    create_join_table :contact_types, :users
    add_index :contact_types_users, [:contact_type_id, :user_id], :name => :contact_types_users_idx1
  end
end
