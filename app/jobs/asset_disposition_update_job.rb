#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob


  def execute_job(asset)
    just_disposed_and_transferred = !asset.disposed? && asset.disposition_updates.last.try(:disposition_type_id) == 2

    asset.record_disposition
    if(just_disposed_and_transferred)
      new_asset = asset.transfer asset.organization_id
      send_asset_transferred_message new_asset
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

  def send_asset_transferred_message asset

    transit_managers = get_users_for_organization asset.organization

    event_url = Rails.application.routes.url_helpers.new_inventory_path asset

    transfer_notification = Notification.create(text: "A new asset has been transferred to you. Please update the asset.", link: event_url, notifiable_type: 'Organization', notifiable_id: asset.organization_id )

    transit_managers.each do |usr|
      UserNotification.create(notification: transfer_notification, user: usr)
    end

  end

  # TODO there is probably a better way
  def get_users_for_organization organization
    user_role = Role.find_by(:name => 'transit_manager')

    unless user_role.nil?
      users = organization.users_with_role user_role.name
    end

    return users || []
  end

end
