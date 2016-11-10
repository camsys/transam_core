module Abilities
  class AuthorizedUserOrganizationFilterAbility
    include CanCan::Ability

    def initialize(user)

      can :manage, UserOrganizationFilter

    end
  end
end