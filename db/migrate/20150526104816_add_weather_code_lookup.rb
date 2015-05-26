class AddWeatherCodeLookup < ActiveRecord::Migration
  def change

    create_table :weather_codes do |t|
      t.string      :state,         :limit => 2,   :null => :false
      t.string      :code,          :limit => 8,   :null => :false
      t.string      :city,          :limit => 64,  :null => :false
      t.boolean     :active,                       :null => :false
    end
    add_index :weather_codes,   [:state, :city], :name => :weather_codes_idx

    add_column :users, :weather_code_id, :integer, :after => :notify_via_email

  end
end
