class AddUserOrganizationFilterTable < ActiveRecord::Migration
  def change

    create_table :user_organization_filters do |t|
      t.string  :object_key,     :limit => 12,   :null => :false
      t.integer :user_id,                        :null => :false
      t.string  :name,           :limit => 64,   :null => :false
      t.string  :description,    :limit => 254,  :null => :false
      t.text    :form_params
      t.boolean :active,                         :null => :false
      
      t.timestamps
    end
    add_index :user_organization_filters, [:object_key],  :name => :user_organization_filters_idx1
    add_index :user_organization_filters, [:user_id],     :name => :user_organization_filters_idx2
    
    # Create a join table for user_organization_filters and organizations
    create_join_table :user_organization_filters, :organizations, :table_name => :user_organization_filters_organizations
    add_index :user_organization_filters_organizations, [:user_organization_filter_id, :organization_id], :name => :user_organization_filters_idx1
    
  end
end
