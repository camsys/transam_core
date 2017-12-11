module Abilities
  class AuthorizedActivityLogAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      cannot :read, ActivityLog

    end
  end
end