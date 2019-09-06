module Abilities
  class AssetManager
    include CanCan::Ability

    def initialize(user)

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, TransamAssetRecord do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && user.viewable_organization_ids.include?(a.organization_id))
      end

      can :manage, EarlyDispositionRequestUpdateEvent do |ae|
        ae.asset_event_type.try(:active)
      end

      can :create, DispositionUpdateEvent

      cannot :create, DispositionUpdateEvent do |ae|
        !(DispositionUpdateEvent.asset_event_type.try(:active) && user.viewable_organization_ids.include?(ae.transam_asset.organization_id))
      end

      cannot :create, EarlyDispositionRequestUpdateEvent do |ae|
        !ae.send(Rails.application.config.asset_base_class_name.underscore).try(:eligible_for_early_disposition_request?)
      end

    end
  end
end