module Abilities
  class AuthorizedAssetAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Assets
      #-------------------------------------------------------------------------
      # Create
      can :create,  [Asset]

      # update assets for any organization in their list
      can :update,  Asset, :organization_id => user.organization_ids
      # Prevent updating or removing assets that have been previously disposed
      cannot [:update, :destroy], Asset do |a|
        a.disposed?
      end

    end
  end
end