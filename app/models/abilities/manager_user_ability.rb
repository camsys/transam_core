module Abilities
  class ManagerUserAbility
    include CanCan::Ability

    def initialize(user)

      can [:create, :update, :authorizations], User

    end
  end
end