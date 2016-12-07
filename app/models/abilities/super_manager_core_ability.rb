module Abilities
  class SuperManagerCoreAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role do |r|
        r.name != "admin"
      end

    end
  end
end