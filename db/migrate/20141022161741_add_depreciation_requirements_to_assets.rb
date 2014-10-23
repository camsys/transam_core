class AddDepreciationRequirementsToAssets < ActiveRecord::Migration
  def change
    # an asset is depreciable or not
    add_column    :assets, :property_type, :string, default: 'depreciable'

    # start date of depreciation (usually same as in_service_date)
    add_column    :assets, :depreciation_start_date, :date

    # date that the book value of the asset is calculated for (usually last day of FY)
    add_column    :assets, :current_depreciation_date, :date

    # depreciated value of the asset on the asset
    add_column    :assets, :book_value, :decimal

    # salvage value of the asset
    add_column    :assets, :salvage_value, :decimal

    # calculated cost from the policy for replacing the asset
    add_column    :assets, :replacement_value, :integer
    
  end
end
