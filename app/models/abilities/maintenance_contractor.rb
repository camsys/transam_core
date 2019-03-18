module Abilities
  class MaintenanceContractor
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      self.merge Abilities::AuthorizedUploadAbility.new(user, organization_ids)
      self.merge Abilities::AuthorizedAssetEventAbility.new(user, organization_ids)

      cannot :read, FileContentType do |f|
        f.name == 'New Inventory'
      end

    end
  end
end