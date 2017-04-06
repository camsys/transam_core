module Abilities
  class AuthorizedCoreAbility
    include CanCan::Ability

    def initialize(user)

      ['ActivityLog', 'Asset', 'AssetEvent', 'AssetGroup', 'Issue', 'Message', 'SavedSearch' ,'Task', 'Upload', 'User', 'UserOrganizationFilter', 'Vendor'].each do |c|
        ability = "Abilities::Authorized#{c}Ability".constantize.new(user)

        self.merge ability if ability.present?
      end

    end
  end
end