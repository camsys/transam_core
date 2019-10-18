# Mainly used for incremental seeding, or data change

namespace :transam_core_data do

  desc "Remove object_key duplicates"
  task :remove_dup_object_keys, [:class_name] => [:environment] do |t, args|
    klass = args[:class_name].constantize
    dups = klass.select(:object_key).group(:object_key).having('count(*) > 1').count

    if dups.count > 0
      to_update_keys = {}
      dupped_keys = dups.keys
      klass.where(object_key: dupped_keys).each do |obj|
        original_key = obj.object_key
        # no need to update the first order, so have a flag to mark it
        # all rest of orders with the same key would be updated with a new object_key
        unless to_update_keys[original_key].present?
          to_update_keys[original_key] = true
          next
        end

        # regenerate object_key
        obj.object_key = nil
        obj.generate_object_key(:object_key)
        obj.save(validate: false)
        puts "#{klass} #{original_key} now has a new key: #{obj.object_key}"
      end
    end
  end

  desc "add super manager role"
  task add_super_manager_role: :environment do
    r = Role.find_or_initialize_by(name: 'super_manager')
    r.resource = Role.find_by(name: 'manager')
    r.weight = 10
    r.privilege = true
    r.save!
  end

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
      unless rule.valid?
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
                  if asset.fuel_type_id == fuel.id
                    asset.check_policy_rule
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
              a = Asset.get_typed_asset(assets.first)
              a.check_policy_rule
            end
          end
        end
      end
    end
  end

  desc "The Issue Report's custom SQL"
  task update_issue_report_with_new_custom_sql: :environment do
    issue_report = Report.find_by(name: 'Issues Report')
    unless issue_report.nil?
      issue_report.class_name = 'CustomSqlReport'
      issue_report.view_name = 'issues_report_table'
      issue_report.custom_sql = "SELECT d.short_name AS 'ORGANIZATION', b.name AS 'TYPE', a.created_at AS 'DATE/TIME', a.comments AS 'COMMENTS', e.name AS 'BROWSER TYPE', c.first_name AS 'FIRST NAME', c.last_name AS 'LAST NAME', c.phone AS 'PHONE', f.name AS 'ISSUE_STATUS' , a.resolution_comments AS 'RESOLUTION_COMMENTS', a.object_key AS 'ISSUE ID' FROM issues a LEFT JOIN issue_types b ON a.issue_type_id=b.id LEFT JOIN users c ON a.created_by_id=c.id LEFT JOIN organizations d ON c.organization_id=d.id LEFT JOIN web_browser_types e ON a.web_browser_type_id=e.id LEFT JOIN issue_status_types f ON a.issue_status_type_id=f.id WHERE a.issue_status_type_id != 2 ORDER BY a.created_at"
      issue_report.save
    end
  end

  desc "Seed issue status types"
  task seed_issue_status_types: :environment do
    issue_status_types = [
        {:active => 1, :name => 'Open',      :description => 'Open'},
        {:active => 1, :name => 'Resolved',  :description => 'Resolved'},
    ]

    issue_status_types.each do |type|
      IssueStatusType.create(type)
    end
  end

  desc "Add activity to send email for issues report weekly"
  task add_issues_report_activity: :environment do

    # old name need to replace if exists
    if Activity.where('name LIKE ?', "%Issues Report").count > 0
      issues_report_activity = Activity.where('name LIKE ?', "%Issues Report").first
    else
      issues_report_activity = Activity.new
    end

    issues_report_activity.attributes = {
        name: 'Issues Report',
        description: 'Report giving an admin a list of all issues.',
        show_in_dashboard: false,
        system_activity: true,
        frequency_quantity: 1,
        frequency_type_id: 3,
        execution_time: '00:01',
        job_name: 'IssuesReportJob',
        active: true
    }
    issues_report_activity.save!
  end
end
