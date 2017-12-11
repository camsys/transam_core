module Abilities
  class AuthorizedUploadAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      #-------------------------------------------------------------------------
      # Uploads
      #-------------------------------------------------------------------------
      can :create,  [Upload]

      # can update and remove uploads as long as they are not being processed
      # checks multi org spreadsheets based on assets linked to uploads
      can [:update, :destroy], Upload do |u|
        asset_ids = Asset.where('organization_id IN (?) AND upload_id IS NOT NULL', organization_ids).pluck(:upload_id)
        ((asset_ids.include? u.id) || (organization_ids.include? u.organization_id)) && ([1,3,4,5].include? u.file_status_type_id)
      end

    end
  end
end