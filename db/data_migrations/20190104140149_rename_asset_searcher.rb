class RenameAssetSearcher < ActiveRecord::DataMigration
  def up
    SearchType.find_by(name: 'Asset').update!(class_name: 'AssetMapSearcher')
  end
end