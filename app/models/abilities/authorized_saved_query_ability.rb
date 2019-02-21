module Abilities
  class AuthorizedSavedQueryAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      can [:create, :show, :export, :query, :export_unsaved, :clone, :save_as], SavedQuery

      can [:update, :destroy], SavedQuery do |query|
        user.id == query.created_by_user_id
      end

    end
  end
end