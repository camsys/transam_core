module Abilities
  class AuthorizedSystemConfigAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      cannot :manage, SystemConfig

    end
  end
end