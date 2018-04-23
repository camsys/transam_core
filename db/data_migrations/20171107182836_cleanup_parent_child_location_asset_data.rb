class CleanupParentChildLocationAssetData < ActiveRecord::DataMigration
  def up
    Asset.where('parent_id IS NOT NULL').map{|x| x.update!(location_id: x.parent_id, parent_id: nil)}
  end
end