module Abilities
  class AuthorizedMessageAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      #-------------------------------------------------------------------------
      # Messages
      #-------------------------------------------------------------------------
      # Create
      can :create,  [Message]

    end
  end
end