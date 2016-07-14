#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Performs all updates on an asset
#
#------------------------------------------------------------------------------
class AssetUpdateAllJob < Job

  attr_accessor :organization
  attr_accessor :asset_types
  attr_accessor :creator

  def run

    # Rip through the organizations assets, creating a job for each type requested
    org = Organization.get_typed_organization(organization)
    assets = org.assets.operational.where(asset_type: asset_types)
    count = assets.count
    assets.find_each do |a|
      typed_asset = Asset.get_typed_asset(a)
      typed_asset.update_methods.each do |m|
        begin
          typed_asset.send(m, false) #dont save until all updates have run
        rescue Exception => e
          Rails.logger.warn e.message
        end
      end
      typed_asset.save
    end

    policy = Policy.active.find_by(organization_id: organization.id)
    if count > 0
      msg = "#{count} assets have been updated using policy #{policy}."
      # Add a row into the activity table
      ActivityLog.create({:organization_id => organization.id, :user_id => creator.id, :item_type => "Policy Asset Update", :activity => msg, :activity_time => Time.current})
    else
      msg = "No assets were updated."
    end

    event_url = Rails.application.routes.url_helpers.policy_path policy
    policy_notification = Notification.create(text: msg, link: event_url)
    UserNotification.create(user: creator, notification: policy_notification)

  end

  def prepare
    Rails.logger.debug "Executing AssetUpdateAllJob at #{Time.now.to_s} for all assets"
  end

  def check
    raise ArgumentError, "organization can't be blank " if organization.nil?
    raise ArgumentError, "asset_types can't be blank " if asset_types.nil?
    raise ArgumentError, "creator can't be blank " if creator.nil?
  end

  def initialize(organization, asset_types, creator)
    super
    self.organization = organization
    self.asset_types = asset_types
    self.creator = creator
  end

end
