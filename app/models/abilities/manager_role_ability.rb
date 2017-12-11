module Abilities
  class ManagerRoleAbility
    include CanCan::Ability

    def initialize(user)

      # if the super manager role exists only super managers can assign all roles (minus admin), managers just can assign users
      # otherwise managers can assign
      if Role.find_by(name: 'super_manager').present?
        can :assign, Role do |r|
          ['user'].include? r.name
        end
      else
        can :assign, Role do |r|
          r.name != "admin"
        end
      end

    end
  end
end