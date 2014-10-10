class IncreasePrecisionForAssetReportedCondition < ActiveRecord::Migration
  def self.up
    change_column :assets, :reported_condition_rating, :decimal, :precision => 10, :scale => 1
  end
  def self.down
    change_column :assets, :reported_condition_rating, :decimal, :precision => 10, :scale => 0
  end
end
