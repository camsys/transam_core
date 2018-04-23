module Abilities
  class AuthorizedAssetAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      #-------------------------------------------------------------------------
      # Assets
      #-------------------------------------------------------------------------
      # Create
      can :create,  [Asset]

      # update assets for any organization in their list
      can :update,  Asset, :organization_id => organization_ids
      # Prevent updating or removing assets that have been previously disposed
      cannot [:update, :destroy], Asset do |a|
        a.disposed?
      end

    end
  end
end