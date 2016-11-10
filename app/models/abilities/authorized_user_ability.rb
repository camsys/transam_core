module Abilities
  class AuthorizedUserAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Users
      #-------------------------------------------------------------------------
      # can update their own user record as long as it is not from dotGrants
      can [:update], User do |usr|
        user.id == usr.id
      end
      # can everything else if they are the current user
      can [:change_password, :update_password, :settings, :profile_photo], User do |usr|
        user.id == usr.id
      end

    end
  end
end