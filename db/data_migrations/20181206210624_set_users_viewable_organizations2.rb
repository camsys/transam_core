class SetUsersViewableOrganizations2 < ActiveRecord::DataMigration
  def up
    # rerun this data migration because realized the fix to set viewable organization_ids happened in core only not cpt
    User.all.each do |user|
      if user.organization.organization_type.class_name == 'Grantor'
        user.viewable_organizations = Organization.all
      else
        user.viewable_organizations = user.organizations
      end
    end
  end
end