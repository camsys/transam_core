class AddWarrantyDateToAsset < ActiveRecord::Migration

  def change
    add_column    :assets, :warranty_date, :date, :after => :purchase_date
  end

end
