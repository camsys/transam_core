module Abilities
  class ManagerRoleAbility
    include CanCan::Ability

    def initialize(user)

      can :assign, Role do |r|
        ['user'].include? r.name
      end

    end
  end
end