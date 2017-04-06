module Abilities
  class AuthorizedSavedSearchAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Issues
      #-------------------------------------------------------------------------
      # A user can manage issues if they created them
      can :manage, SavedSearch do |search|
        user.id == search.user_id
      end

    end
  end
end