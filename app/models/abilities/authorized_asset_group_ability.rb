module Abilities
  class AuthorizedAssetGroupAbility
    include CanCan::Ability

    def initialize(user)

      # Can manage asset groups if the group is owned by their organiation
      can :manage, AssetGroup, :organization_id => user.organization_ids

    end
  end
end