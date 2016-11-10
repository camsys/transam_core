module Abilities
  class ManagerUserAbility
    include CanCan::Ability

    def initialize(user)

      can [:create, :update], User

    end
  end
end