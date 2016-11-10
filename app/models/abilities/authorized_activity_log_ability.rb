module Abilities
  class AuthorizedActivityLogAbility
    include CanCan::Ability

    def initialize(user)

      cannot :read, ActivityLog

    end
  end
end