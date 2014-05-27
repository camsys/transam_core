class UpdateAssetEvents < ActiveRecord::Migration
  def change
    add_column  :asset_events, :location_id,        :integer, :after => :current_mileage
    add_column  :asset_events, :replacement_year,   :integer, :after => :location_id
    add_column  :asset_events, :rebuild_year,       :integer, :after => :replacement_year
  end
end
