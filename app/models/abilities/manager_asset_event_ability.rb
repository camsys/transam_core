module Abilities
  class ManagerAssetEventAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Asset Events
      #-------------------------------------------------------------------------
      # managers can manage asset events if the asset's organization is in their list
      can :manage, AssetEvent do |ae|
        ae.asset_event_type.try(:active) && user.organization_ids.include?(ae.send(Rails.application.config.asset_base_class_name.underscore).try(:organization_id))
      end

      can :manage, EarlyDispositionRequestUpdateEvent do |ae|
        ae.asset_event_type.try(:active)
      end

      cannot :create, DispositionUpdateEvent do |ae|
        !(DispositionUpdateEvent.asset_event_type.try(:active) && user.viewable_organization_ids.include?(ae.transam_asset.organization_id))
      end

      cannot :create, EarlyDispositionRequestUpdateEvent do |ae|
        !ae.send(Rails.application.config.asset_base_class_name.underscore).try(:eligible_for_early_disposition_request?)
      end

    end
  end
end