class AddScheduleTable < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      
      t.string     :object_key,            :limit => 12, :null => :false
      t.references :organization_type
      t.string     :name,                  :limit => 64, :null => :false
      t.text       :description,                         :null => :false
      
      t.boolean    :show_in_dashboard
      
      t.string     :schedule,              :limit => 64, :null => :false
      t.string     :due,                   :limit => 64, :null => :false
      t.string     :notify,                :limit => 64, :null => :false
      t.string     :warn,                  :limit => 64, :null => :false
      t.string     :alert,                 :limit => 64, :null => :false
      t.string     :escalate,              :limit => 64, :null => :false

      t.string     :job_name,              :limit => 64, :null => :false
      
      t.datetime   :last_run             
      
      t.boolean    :active
      t.timestamps
    end
    
  end
end
