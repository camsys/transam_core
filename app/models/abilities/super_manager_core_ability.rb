module Abilities
  class SuperManagerCoreAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role

    end
  end
end