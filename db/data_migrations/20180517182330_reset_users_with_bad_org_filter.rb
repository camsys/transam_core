class ResetUsersWithBadOrgFilter < ActiveRecord::DataMigration
  def up
    User.where.not(user_organization_filter_id: UserOrganizationFilter.ids).each{|user| user.update!(user_organization_filter: user.user_organization_filters.system_filters.first)}
  end
end