class AddCoreAssetMapSearcherMixin < ActiveRecord::DataMigration
  def up
    SystemConfigExtension.find_or_create_by(class_name: 'AssetMapSearcher', extension_name: 'CoreAssetMapSearchable', active: true)
  end

  def down
    SystemConfigExtension.find_by(class_name: 'AssetMapSearcher', extension_name: 'CoreAssetMapSearchable').destroy
  end
end