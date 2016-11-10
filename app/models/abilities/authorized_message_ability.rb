module Abilities
  class AuthorizedMessageAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Messages
      #-------------------------------------------------------------------------
      # Create
      can :create,  [Message]

    end
  end
end