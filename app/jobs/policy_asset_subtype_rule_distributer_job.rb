#------------------------------------------------------------------------------
#
# AssetUpdateJob
#
# Performs all updates on an asset
#
#------------------------------------------------------------------------------
class PolicyAssetSubtypeRuleDistributerJob < Job

  attr_accessor :policy_asset_subtype_rules
  attr_accessor :is_mileage

  def run
    PolicyAssetSubtypeRule.where(id: policy_asset_subtype_rules).each do |policy_asset_subtype_rule|
      policy_asset_subtype_rule.send(:apply_policy)
    end

    event_url = Rails.application.routes.url_helpers.policy_path Policy.find_by(parent_id: nil)
    if is_mileage
      msg = 'Parent policy distributed and assets updated for new policy mileage rules.'
    else
      msg = 'Parent policy distributed and assets updated for new policy rules.'
    end

    # Add a row into the activity table
    ActivityLog.create({:organization_id =>Grantor.first.id, :user_id => User.find_by(first_name: 'system').id, :item_type => "Policy Asset Subtype Rule Distributor", :activity => msg, :activity_time => Time.now})

    policy_notification = Notification.create(text: msg, link: event_url, notifiable_type: 'Organization', notifiable_id: Grantor.first.id)
    UserNotification.create(user: User.find_by(first_name: 'system'), notification: policy_notification)


  end

  def prepare
    Rails.logger.debug "Executing PolicyAssetSubtypeRuleDistributerJob at #{Time.now.to_s} for all assets"
  end

  def check
    raise ArgumentError, "policy asset subtype rules can't be blank " if policy_asset_subtype_rules.nil?
  end

  def initialize(rule_ids, is_mileage=false)
    super
    self.policy_asset_subtype_rules = rule_ids
    self.is_mileage = is_mileage
  end

end
