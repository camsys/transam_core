#------------------------------------------------------------------------------
#
# AssetDepreciationExpenseUpdateJob
#
#
#------------------------------------------------------------------------------
class AssetServiceLifeUpdateJob < ActivityJob


  def run
    # Service life calculators with 'AND mileage/condition' could possibly set policy replacement year = planning year + 1
    # as planning year changes at rollover a background job has to run to update these values
    # set this up as an activity to run once a month but activity can be changed to run as often as you want to see if the 'AND' condition has been met changing the policy replacement year
    rules = PolicyAssetTypeRule.joins(:service_life_calculation_type).where('service_life_calculation_types.class_name LIKE ?', "%#{'And'}%").where.not(policy_id: Policy.find_by(parent_id: nil).id)
    rules.each do |rule|
      assets = Rails.application.config.asset_base_class_name.constantize.operational.joins(asset_subtype: :asset_type).where(organization_id: rule.policy.organization_id, asset_types: {id: rule.asset_type_id})
      assets.each do |asset|
        asset.save! # trigger callbacks
      end
    end

  end

  def clean_up
    super
    Rails.logger.debug "Completed AssetServiceLifeUpdateJob at #{Time.now.to_s}"
  end

  def prepare
    super
    Rails.logger.debug "Executing AssetServiceLifeUpdateJob at #{Time.now.to_s}"
  end

end