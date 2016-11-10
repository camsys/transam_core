module Abilities
  class ManagerAssetAbility
    include CanCan::Ability

    def initialize(user)

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, Asset do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(true) && user.organization_ids.include?(a.organization_id))
      end

      can :destroy, Asset

    end
  end
end