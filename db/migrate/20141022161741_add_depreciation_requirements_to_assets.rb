class AddDepreciationRequirementsToAssets < ActiveRecord::Migration
  def change
    # an asset is depreciable or not
    add_column    :assets, :is_depreciable, :boolean, :default => true, :after => :estimated_value

    # start date of depreciation (usually same as in_service_date)
    add_column    :assets, :depreciation_start_date, :date, :after => :is_depreciable

    # date that the book value of the asset is calculated for (usually last day of FY)
    add_column    :assets, :current_depreciation_date, :date, :after => :depreciation_start_date

    # depreciated value of the asset on the asset
    add_column    :assets, :book_value, :decimal, :after => :current_depreciation_date

    # salvage value of the asset
    add_column    :assets, :salvage_value, :decimal, :after => :book_value

  end
end
