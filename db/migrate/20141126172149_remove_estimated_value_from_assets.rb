class RemoveEstimatedValueFromAssets < ActiveRecord::Migration
  def change
    remove_column :assets, :estimated_value
  end
end
