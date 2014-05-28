class AddRehabToPolicyItem < ActiveRecord::Migration
  def change
    add_column  :policy_items, :rehabilitation_cost,          :integer, :after => :replacement_cost
    add_column  :policy_items, :extended_service_life_years,  :integer, :after => :rehabilitation_cost
    add_column  :policy_items, :extended_service_life_miles,  :integer, :after => :extended_service_life_years
  end
end
