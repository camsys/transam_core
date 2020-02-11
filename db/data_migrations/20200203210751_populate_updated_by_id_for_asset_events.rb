class PopulateUpdatedByIdForAssetEvents < ActiveRecord::DataMigration
  def up
    AssetEvent.where.not(created_by_id: nil).where(updated_by_id: nil).each do |e|
      e.update_column(:updated_by_id, e.created_by_id)
    end
  end
end