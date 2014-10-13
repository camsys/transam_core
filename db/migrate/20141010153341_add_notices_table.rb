class AddNoticesTable < ActiveRecord::Migration
  def change
    create_table :notice_types do |t|
      t.string      :name,                :limit => 64, :null => :false
      t.string      :description,         :limit => 254,:null => :false
      t.string      :display_icon,        :limit => 64, :null => :false
      t.string      :display_class,       :limit => 64, :null => :false
      t.boolean    :active
    end

    create_table :notices do |t|
      
      t.string     :object_key,            :limit => 12, :null => :false
      t.references :organization_type
      t.string     :subject,               :limit => 64, :null => :false
      t.string     :summmary,              :limit => 128,:null => :false
      t.text       :details,                             :null => :false
      t.references :notice_type,                         :null => :false
      
      t.datetime   :display_datetime             
      t.datetime   :end_datetime             
      
      t.boolean    :active
      t.timestamps
      
    end
    
  end
end
