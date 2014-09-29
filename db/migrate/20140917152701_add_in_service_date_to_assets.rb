class AddInServiceDateToAssets < ActiveRecord::Migration
  def change
    # Add a string column contianing a comma-delimited list of roles that are allowed
    # to view the report
    add_column    :assets, :in_service_date, :date, :after => :purchase_date

    Asset.connection.execute('UPDATE `assets` SET `in_service_date` = `purchase_date`')    
  end
end
