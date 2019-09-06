class AddAssetManagerPrivilege < ActiveRecord::DataMigration
  def up
    Role.create!(name: 'asset_manager', show_in_user_mgmt: true, privilege: true, label: 'Asset Manager', role_parent: Role.find_by(name: 'manager'))
  end

  def down
    Role.find_by(name: 'asset_manager').destroy!
  end
end