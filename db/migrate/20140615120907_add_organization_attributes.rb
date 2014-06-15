class AddOrganizationAttributes < ActiveRecord::Migration
  def change

    # Urban Rural Type Lookup
    create_table :urban_rural_types do |t|
      t.string  :name,           :limit => 64,   :null => :false
      t.string  :description,    :limit => 254,  :null => :false
      t.boolean :active,                         :null => :false
    end
    
    add_column  :organizations, :urban_rural_type_id,       :integer, :after => :indian_tribe

    add_index   :organizations, :urban_rural_type_id, :name => :orgnizations_idx5

  end
  
end
