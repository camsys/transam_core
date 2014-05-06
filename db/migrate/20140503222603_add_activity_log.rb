class AddActivityLog < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.integer   :organization_id,                 :null => false
      t.string    :item_type,         :limit => 64, :null => false, :default => 'Object'
      t.integer   :item_id
      t.integer   :user_id,                         :null => false
      t.text      :activity,                        :null => false
      t.datetime  :activity_time,                                   :default => Time.now
    end
    add_index :activity_logs, [:organization_id, :activity_time], :name => "activity_logs_idx1"    
    add_index :activity_logs, [:user_id, :activity_time], :name => "activity_logs_idx2"    
  end
end
