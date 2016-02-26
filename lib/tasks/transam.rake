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
    Asset.find_each do |a|
      a.record_disposition
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
end
