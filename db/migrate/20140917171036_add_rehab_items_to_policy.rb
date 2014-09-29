class AddRehabItemsToPolicy < ActiveRecord::Migration
  
  def change
    # Add another index for fuel type
    add_column    :policy_items, :fuel_type_id, :integer, :after => :asset_subtype_id
    
    # Allow the user to set the default replacement code (eg 11.12.XX or 11.16.XX) for each line item
    add_column    :policy_items, :replacement_ali_code, :string, :limit => 8, :after => :replacement_cost
    # Allow the user to set the default replacement technologies for each line item 
    add_column    :policy_items, :replace_asset_subtype_id, :integer, :after => :replacement_ali_code
    add_column    :policy_items, :replace_fuel_type_id, :integer, :after => :replace_asset_subtype_id
    # Allow the user to set the default rehabilitation code (eg 11.14.XX or 11.17.XX) for each line item
    add_column    :policy_items, :rehabilitation_ali_code, :string, :limit => 8, :after => :rehabilitation_cost
    add_column    :policy_items, :rehabilitation_year, :integer, :after => :rehabilitation_ali_code
    
  end
  
end
