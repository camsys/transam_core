class UpdateCoreRoles < ActiveRecord::DataMigration
  def up
    Role.where(name: [:user, :manager]).update_all(label: 'Staff')
    Role.find_by(name: :super_manager).update(label: 'Grantor Manager', privilege: false)
  end

  def down
    Role.find_by(name: :super_manager).update(label: nil, privilege: true)
    Role.where(name: [:user, :manager]).update_all(label: nil)
  end
end