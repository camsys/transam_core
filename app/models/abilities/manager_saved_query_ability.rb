module Abilities
  class ManagerSavedQueryAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      # own org's manager can edit and share a saved query
      can [:share, :manage], SavedQuery do |query|
        organization_ids.include?(query.created_by_user.try(:organization_id))
      end 

      # can remove saved_query shared from other
      can :remove, SavedQuery
    end
  end
end