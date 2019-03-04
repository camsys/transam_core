module Abilities
  class AuthorizedCoreAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      ['ActivityLog', 'Asset', 'AssetEvent', 'AssetGroup', 'Issue', 'Message', 'SavedSearch' ,'Task', 'Upload', 'User', 'UserOrganizationFilter', 'Vendor', 'SavedQuery'].each do |c|
        ability = "Abilities::Authorized#{c}Ability".constantize.new(user, organization_ids)

        self.merge ability if ability.present?
      end

    end
  end
end