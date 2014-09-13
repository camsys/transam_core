class MoveScheduledDispositionFieldToYear < ActiveRecord::Migration
  def change
    # Drop the scheduled_dispositon_date field and replace with scheduled_disposition_year
    # Assets Table
    add_column    :assets, :scheduled_disposition_year, :integer, :after => :scheduled_rehabilitation_year
    remove_column :assets, :scheduled_disposition_date  
    # Asset Events Table
    add_column    :asset_events, :disposition_year, :integer, :after => :rebuild_year
  end
end
