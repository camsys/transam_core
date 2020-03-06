class CleanupAdminPrivileges < ActiveRecord::DataMigration
  def up

    Role.where.not(name: 'guest').each do |r|
      Role.where(show_in_user_mgmt: true, name: ['admin','system_admin']).each do |p|
        RolePrivilegeMapping.create!(role_id: r.id, privilege_id: p.id)
      end
    end

  end
end