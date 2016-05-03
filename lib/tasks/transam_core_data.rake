# Mainly used for incremental seeding, or data change

namespace :transam_core_data do
  desc "Add event type for EarlyDispositionRequestUpdateEvent"
  task add_early_disposition_request_event_type: :environment do
    if AssetEventType && AssetEventType.where(class_name: 'EarlyDispositionRequestUpdateEvent').empty?
      config = {
        :active => 1,
        :name => 'Request early disposition',
        :display_icon_name => "fa fa-ban",
        :description => 'Early Disposition Request',
        :class_name => 'EarlyDispositionRequestUpdateEvent',
        :job_name => ''
      }
      AssetEventType.new(config).save
    end
  end

  desc "Add a default asset_subtype/fuel_type rule"
  task default_subtype_with_generic_fuel_rule_data: :environment do
    %w(transam_core_data:default_parent_fuel_rule_to_nil transam_core_data:validate_asset_and_fuel_rules_unique transam_core_data:update_assets_without_rules).each do |cmd|
      puts "Running #{cmd} for transam_core_data"
      Rake::Task[cmd].invoke
    end
  end

  desc "Set the Parent Policy Default Asset Type and Fuel Rules to have a nil fuel type"
  task default_parent_fuel_rule_to_nil: :environment do
    default_assets_rules = PolicyAssetSubtypeRule.where(policy_id: 1, default_rule: 1)
    default_assets_rules.update_all(fuel_type_id: nil)
  end

  desc "Validate all asset subtype and fuel rules are unique"
  task validate_asset_and_fuel_rules_unique: :environment do
    all_policy_asset_subtype_rules = PolicyAssetSubtypeRule.all

    all_policy_asset_subtype_rules.each do |rule|
      if !rule.valid?
        puts "#{rule} with id #{rule.id} with an asset subtype of #{rule.asset_subtype} and a fuel type #{rule.fuel_type_id} failed validation. Likely due to the uniqueness constraint."
      end
    end
  end

  desc "Updates all assets without a policy subtype rule and force them to have a policy subtype rule"
  task update_assets_without_rules: :environment do
    # organizations = Organization.all
    asset_subtypes = AssetSubtype.all
    fuel_types = FuelType.all
    policies = Policy.distinct
    assets = []

    asset_subtypes.each do |subtype|
      # if Asset.get_typed_asset(subtype).respond_to? :fuel_type
      assetType = AssetType.where(id: subtype.asset_type_id)
      if assetType.first.class_name.constantize.new.respond_to? :fuel_type
        fuel_types.each do |fuel|
          policies.each do |policy|
            assets = PolicyAssetSubtypeRule.where(policy_id: policy.id, fuel_type_id: fuel.id, asset_subtype_id: subtype.id)
            if assets.nil? || assets.empty?
              assets = Asset.where(organization_id: policy.organization.id, asset_subtype_id: subtype.id)
              if !assets.nil? && assets.length > 0
                puts "Updating rules for assets with subtype #{subtype.id}, #{policy} in #{policy.organization} for #{fuel}"
                assets.each do |a|
                  asset = Asset.get_typed_asset(a)
                  if asset.fuel_type.id == fuel.id
                    a.check_policy_rule
                    break
                  end
                end
              end
            end
          end
        end
      else
        policies.each do |policy|
          assets = PolicyAssetSubtypeRule.where(policy_id: policy.id, asset_subtype_id: subtype.id)
          if assets.nil? || assets.empty?
            assets = Asset.where(organization_id: policy.organization.id, asset_subtype_id: subtype.id)
            if !assets.nil? && assets.length > 0
              puts "Updating rules for assets with subtype #{subtype.id} and organization #{policy.organization},  #{assets.length} assets had no rules."
              assets.first.check_policy_rule
            end
          end
        end
      end
    end
  end

end
