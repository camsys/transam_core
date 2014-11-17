class AddVendorModel < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string    :object_key,      :limit => 12, :null => :false
      t.string    :name,            :limit => 64, :null => :false
      t.string    :address1,        :limit => 128
      t.string    :address2,        :limit => 128
      t.string    :city,            :limit => 64
      t.string    :state,           :limit => 2
      t.string    :zip,             :limit => 10
      t.string    :phone,           :limit => 12
      t.string    :fax,             :limit => 12
      t.string    :url,             :limit => 128
      t.decimal   :latitude,                      :precision => 11, :scale => 6
      t.decimal   :longitude,                     :precision => 11, :scale => 6
      t.boolean   :active
      t.timestamps
    end
    
    add_index :vendors, :object_key,       :unique => :true,  :name => :vendors_idx1
    add_index :vendors, :name,                                :name => :vendors_idx2

    add_column    :assets, :vendor_id, :integer, :after => :manufacture_year
    
  end
end
