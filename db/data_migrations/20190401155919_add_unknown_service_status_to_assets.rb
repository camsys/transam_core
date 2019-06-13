class AddUnknownServiceStatusToAssets < ActiveRecord::DataMigration
  def up
    # add unknown service status type
    unknown_service_type = ServiceStatusType.find_by_code('U')
    if !unknown_service_type
      unknown_service_type = ServiceStatusType.create(active: false, name: 'Unknown', code: 'U', description: 'Asset service status is unknown.')
    end

    # get IDs of transam_assets without service_Status_update_event
    unknown_service_asset_ids = TransamAsset.all.pluck(:id) - ServiceStatusUpdateEvent.pluck(:transam_asset_id).uniq
    ActiveRecord::Base.transaction do
      unknown_service_asset_ids.each do |asset_id|
        ServiceStatusUpdateEvent.create(transam_asset_type: 'TransamAsset', transam_asset_id: asset_id, service_status_type_id: unknown_service_type.id)
      end
    end
  end
end