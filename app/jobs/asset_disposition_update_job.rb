#------------------------------------------------------------------------------
#
# AssetDispositionUpdateJob
#
# Records that an asset has been disposed.
#
#------------------------------------------------------------------------------
class AssetDispositionUpdateJob < AbstractAssetUpdateJob
  
  
  def execute_job(asset)
    asset_event_type = AssetEventType.where(:class_name => 'DispositionUpdateEvent').first
    asset_event = AssetEvent.where(:asset_id => asset.id, :asset_event_type_id => asset_event_type.id).last
    if(asset_event.disposition_type_id == 2)
      new_asset = asset.transfer asset_event.organization_id
      send_asset_trasnferred_message new_asset
    end

    asset.record_disposition
  end

  def prepare
    Rails.logger.debug "Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{object_key}"    
  end

  def send_asset_trasnferred_message asset
    # Get the system user
    sys_user = get_system_user

    # Get the admin users
    admins = get_users_for_organization asset.organization

    # Get the priority
    priority_type = PriorityType.find_by_name('Normal')

    event_url = Rails.application.routes.url_helpers.edit_inventory_path asset
    # Send a message to the admins for this user organization
    admins.each do |admin|
      msg = Message.new
      msg.user          = sys_user
      msg.to_user       = admin
      msg.subject       = "A new asset has been transferred to you"
      msg.body          = "Before the asset can be used some details need to be updated. The asset can be updated at <a href='#{event_url}'>here</a>"
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