class AddReplacementCostsToAssets < ActiveRecord::Migration
  def change
    add_column    :assets, :scheduled_replacement_cost,     :integer, :after => :scheduled_by_user
    add_column    :assets, :scheduled_replace_with_new,     :boolean, :after => :scheduled_replacement_cost
    add_column    :assets, :scheduled_rehabilitation_cost,  :integer, :after => :scheduled_replace_with_new
  end
end
