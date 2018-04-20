class CleanupPrivilegeFieldsRoles < ActiveRecord::DataMigration
  def up
    Role.privileges.where('resource_type IS NOT NULL').each do |privilege|
      privilege.update!(role_parent_id: privilege.resource_id, resource: nil)
    end

    Role.privileges.update_all(show_in_user_mgmt: true)
  end
end