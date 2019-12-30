class UpdateAssetTagLabelInQueryTool < ActiveRecord::DataMigration
  def up
    QueryField.find_by(name: 'asset_tag')&.update!(label: 'Asset ID')
  end
end