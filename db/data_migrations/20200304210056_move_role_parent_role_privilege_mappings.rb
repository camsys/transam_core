class MoveRoleParentRolePrivilegeMappings < ActiveRecord::DataMigration
  def up
    Role.where.not(role_parent: nil).each do |role|
      RolePrivilegeMapping.create!(role_id: role.role_parent_id, privilege_id: role.id)
    end
  end
end