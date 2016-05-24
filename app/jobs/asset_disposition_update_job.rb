#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob


  def execute_job(asset)
    # If the asset has already been transferred then this is an update to the disposition and we don't want to create another asset.
    asset_event_type = AssetEventType.where(:class_name => 'DispositionUpdateEvent').first
    asset_event = AssetEvent.where(:asset_id => asset.id, :asset_event_type_id => asset_event_type.id).last
    disposition_type = DispositionType.where(:id => asset_event.disposition_type_id)

    asset_already_transferred = asset.disposed disposition_type

    asset.record_disposition
    if(!asset_already_transferred && asset_event.disposition_type_id == 2)
      new_asset = asset.transfer asset_event.organization_id
      send_asset_transferred_message new_asset
    end
  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

  def send_asset_transferred_message asset
    # Get the system user
    sys_user = get_system_user

    # Get the admin users
    admins = get_users_for_organization asset.organization

    # Get the priority
    priority_type = PriorityType.find_by_name('Normal')

    event_url = Rails.application.routes.url_helpers.new_inventory_path asset
    # Send a message to the admins for this user organization
    admins.each do |admin|
      msg = Message.new
      msg.user          = sys_user
      msg.to_user       = admin
      msg.subject       = "A new asset has been transferred to you."
      msg.body          = "Before the asset can be used some details need to be updated. The asset can be updated <a href='#{event_url}'>here</a>, be sure your filters are clear or grant you permissions to access assets for #{asset.organization.name}."
      msg.priority_type = priority_type
      msg.organization  = asset.organization
      msg.save
    end
  end

  # TODO there is probably a better way
  def get_users_for_organization organization
    user_role = Role.where(:name => 'transit_manager').first

    users = find_users(organization, user_role)

    if users.empty?
      Role.where(:name => 'manager').first
      users = find_users(organization, user_role)
      if users.empty?
        Role.where(:name => 'admin').first
        users = find_users(organization, user_role)
      end
    end

    return users
  end

  def find_users(organization, user_role)
    users = []
    unless user_role.nil?
      users = organization.users_with_role user_role.name
    end

    return users
  end

end
