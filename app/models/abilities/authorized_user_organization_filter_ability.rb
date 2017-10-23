module Abilities
  class AuthorizedUserOrganizationFilterAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      can :manage, UserOrganizationFilter

    end
  end
end