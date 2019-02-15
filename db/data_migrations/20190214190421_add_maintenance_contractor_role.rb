class AddMaintenanceContractorRole < ActiveRecord::DataMigration
  def up
    Role.create!(name: 'maintenance_contractor', role_parent: Role.find_by(name: 'guest'), show_in_user_mgmt: true, privilege: true, label: 'Maintenance - Contractor')
  end
end