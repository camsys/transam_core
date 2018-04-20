class SetUsersViewableOrganizations < ActiveRecord::DataMigration
  def up
    User.all.each do |user|
      if user.organization.organization_type.class_name == 'Grantor'
        user.viewable_organizations = Organization.all
      else
        user.viewable_organizations = user.organizations
      end
    end
  end
end