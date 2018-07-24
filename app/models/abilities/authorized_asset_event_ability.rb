module Abilities
  class AuthorizedAssetEventAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      #-------------------------------------------------------------------------
      # Asset Events
      #-------------------------------------------------------------------------
      # Can manage asset events if the asset is owned by their organization
      can :manage, AssetEvent do |ae|
        ae.asset_event_type.try(:active) && organization_ids.include?(ae.asset.organization_id)
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


      # Can manage asset events if the asset is owned by their organization
      can :manage, AssetEvent do |ae|
        ae.asset_event_type.try(:active) && organization_ids.include?(ae.transam_asset.organization_id)
      end

      cannot :create, DispositionUpdateEvent do |ae|
        !ae.transam_asset.disposable?(false)
      end


      cannot :create, EarlyDispositionRequestUpdateEvent do |ae|
        !ae.transam_asset.eligible_for_early_disposition_request?
      end

    end
  end
end