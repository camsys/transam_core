module Abilities
  class AuthorizedAssetGroupAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      # Can manage asset groups if the group is owned by their organiation
      can :manage, AssetGroup, :organization_id => organization_ids

    end
  end
end