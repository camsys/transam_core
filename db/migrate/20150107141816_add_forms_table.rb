class AddFormsTable < ActiveRecord::Migration

  def change
    create_table :forms do |t|
      t.string    :object_key,      :limit => 12,   :null => :false
      t.string    :name,            :limit => 64,   :null => :false
      t.string    :description,     :limit => 254,  :null => :false

      t.string    :name,            :limit => 64,   :null => :false
      t.string    :roles,           :limit => 128,  :null => :false

      t.string    :controller,      :limit => 64,   :null => :false

      t.boolean   :active

      t.timestamps
    end

    add_index :forms, :object_key,       :unique => :true,  :name => :forms_idx1

  end
end
