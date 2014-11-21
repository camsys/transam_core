class AddOrganizationToVendor < ActiveRecord::Migration
  def change
    add_column    :vendors, :organization_id, :integer, :after => :object_key

    add_index     :vendors, :organization_id,       :name => :vendors_idx3

    
  end
end
