class AddReportedMileageDateToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :reported_mileage_date, :date, :after => :reported_mileage
  end
end
