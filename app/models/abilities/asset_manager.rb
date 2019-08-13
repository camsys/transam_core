module Abilities
  class AssetManager
    include CanCan::Ability

    def initialize(user)

      # Only allow users to dispose of assets that are disposable and that they
      # own
      can :dispose, Asset do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(true) && user.organization_ids.include?(a.organization_id))
      end

      can :dispose, TransamAssetRecord do |a|
        (DispositionUpdateEvent.asset_event_type.try(:active) && a.disposable?(true) && user.organization_ids.include?(a.organization_id))
      end

      # can manage asset events if the asset's organization is in their list
      can :manage, AssetEvent do |ae|
        ae.asset_event_type.try(:active) && user.organization_ids.include?(ae.send(Rails.application.config.asset_base_class_name.underscore).try(:organization_id))
      end

      can :manage, EarlyDispositionRequestUpdateEvent do |ae|
        ae.asset_event_type.try(:active)
      end

      cannot :create, DispositionUpdateEvent do |ae|
        !ae.send(Rails.application.config.asset_base_class_name.underscore).try(:disposable?,true)
      end

      cannot :create, EarlyDispositionRequestUpdateEvent do |ae|
        !ae.send(Rails.application.config.asset_base_class_name.underscore).try(:eligible_for_early_disposition_request?)
      end

    end
  end
end