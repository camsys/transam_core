class FixQuantityUnit < ActiveRecord::DataMigration
  def up
    TransamAsset.operational.where(quantity_unit: '1').update_all(quantity_unit: 'unit')
  end
end