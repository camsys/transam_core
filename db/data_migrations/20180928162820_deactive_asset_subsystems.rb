class DeactiveAssetSubsystems < ActiveRecord::DataMigration
  def up
    AssetSubsystem.all.update_all(active: false)
  end
end