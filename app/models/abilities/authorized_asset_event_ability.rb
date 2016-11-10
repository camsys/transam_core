module Abilities
  class AuthorizedAssetEventAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Asset Events
      #-------------------------------------------------------------------------
      # Can manage asset events if the asset is owned by their organization
      can :manage, AssetEvent do |ae|
        ae.asset_event_type.try(:active) && user.organization_ids.include?(ae.asset.organization_id)
      end

      cannot :create, DispositionUpdateEvent do |ae|
        !ae.asset.disposable?(false)
      end


      cannot :create, EarlyDispositionRequestUpdateEvent do |ae|
        !ae.asset.eligible_for_early_disposition_request?
      end

      cannot [:approve, :reject, :approve_via_transfer], EarlyDispositionRequestUpdateEvent

      cannot [:update, :destroy], EarlyDispositionRequestUpdateEvent do |ae|
        ae.state != 'new'
      end

    end
  end
end