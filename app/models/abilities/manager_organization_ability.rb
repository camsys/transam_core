module Abilities
  class ManagerOrganizationAbility
    include CanCan::Ability

    def initialize(user)

      # can update organization records
      can :update, Organization

    end
  end
end