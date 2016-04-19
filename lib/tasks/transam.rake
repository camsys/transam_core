namespace :transam do
  desc "Updates the condition of every asset"
  task update_condition: :environment do
    Asset.find_each do |a|
      a.update_condition
    end
  end
  desc "Updates the service status of every asset"
  task update_service_status: :environment do
    Asset.find_each do |a|
      a.update_service_status
    end
  end
  desc "Updates the estimated value of every asset"
  task update_book_value: :environment do
    Asset.find_each do |a|
      a.update_book_value
    end
  end
  desc "Updates the estimated replacement cost of every asset"
  task update_estimated_replacement_cost: :environment do
    Asset.find_each do |a|
      a.update_estimated_replacement_cost
    end
  end
  desc "Updates the disposition of every asset"
  task update_disposition: :environment do

      a.record_disposition
    end
  end

  desc "Updates all assets without a policy to force them to have a policy"
  task update_assets_without_rules: :environment do
    asset_subtypes = AssetSubtype.all
    fuel_types = FuelType.all
    totalAssets = Asset.all
    assets = []

    puts "Total asset_subtypes #{asset_subtypes.length}"
    puts "Total fuel_types #{fuel_types.length}"
    puts "Total total assets #{totalAssets.length}"

    asset_subtypes.each do |subtype|
      # if(subtype.id == 70)
      # else

        puts "Working with  #{subtype.full_name} and an id of #{subtype.id}"
        rules = PolicyAssetSubtypeRule.where(asset_subtype_id: subtype.id, fuel_type_id: nil)

        if rules.empty?
          assets = Asset.where(asset_subtype_id: subtype.id)
        else
          fuel_types.each do |fuel|
            rules = PolicyAssetSubtypeRule.where(asset_subtype_id: subtype.id, fuel_type_id: fuel.id)
            if rules.empty?
              assets.concat(Asset.where(asset_subtype_id: subtype.id, fuel_type_id: fuel.id))
            end
          end
        end

      # end


    end

    puts "Total assets without policies #{assets.length}"

    # Asset.find_each do |a|
    assets.each do |a|
      if(!a.nil?)
        puts "Working with Asset id #{a.object_key} with name #{a} with a policy object key of #{a.policy.object_key} and #{a.policy.parent}"
        asset = Asset.get_typed_asset(a)
        asset.check_policy_rule
        asset.save
      end
    end
  end

  desc "Updates the sogr of every asset"
  task update_sogr: :environment do
    Asset.find_each do |a|
      a.update_sogr
    end
  end

  desc "Updates all updateable attributes.  Can accept a sql fragment to restrict"
  task :update_all, [:sql_frag] => [:environment] do |t, args|
    t_start = Time.now
    # `rake transam:update_all['organization_id is null']` becomes
    # Asset.where("organization_id is null")
    if args[:sql_frag]
      asset_set = Asset.where(args[:sql_frag])
    else
      asset_set = Asset
    end
    total_num  = asset_set.count.to_f
    percentage = total_num / 100
    assets_run = 0
    asset_set.find_each do |a|
      typed_asset = Asset.get_typed_asset(a)
      typed_asset.update_methods.each do |m|
        begin
          typed_asset.send(m)
        rescue Exception => e
          Rails.logger.warn e.message
        end
      end
      assets_run += 1
      puts "#{assets_run} (#{((assets_run / total_num) * 100).to_i}%)"
    end
    t_finish = Time.now
    puts "Completed in #{t_finish - t_start} seconds"
  end
