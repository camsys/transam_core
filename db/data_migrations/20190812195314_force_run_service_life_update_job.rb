class ForceRunServiceLifeUpdateJob < ActiveRecord::DataMigration
  def up
    if SystemConfigExtension.find_by(extension_name: 'PolicyAware', active: true)
      rules = PolicyAssetTypeRule.joins(:service_life_calculation_type).where('service_life_calculation_types.class_name LIKE ?', "%#{'And'}%").where.not(policy_id: Policy.find_by(parent_id: nil).id)
      rules.each do |rule|
        assets = Rails.application.config.asset_base_class_name.constantize.operational.joins(asset_subtype: :asset_type).where(organization_id: rule.policy.organization_id, asset_types: {id: rule.asset_type_id})
        assets.each do |asset|
          asset.save! # trigger callbacks
        end
      end
    end
  end
end