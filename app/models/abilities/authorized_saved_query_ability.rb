module Abilities
  class AuthorizedSavedQueryAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      can [:create, :update, :delete], SavedQuery do |query|
        user.id == query.created_by_user_id
      end

    end
  end
end