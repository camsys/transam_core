module Abilities
  class ManagerOrganizationAbility
    include CanCan::Ability

    def initialize(user)

      # can update organization records
      can :update, Organization

      can :authorize, Organization

    end
  end
end