namespace :transam do
  desc "Updates the condition of every asset"
  task update_condition: :environment do
    Asset.all.each do |a|
      a.update_condition
    end
  end
  desc "Updates the service status of every asset"
  task update_service_status: :environment do
    Asset.all.each do |a|
      a.update_service_status
    end
  end
  desc "Updates the estimated value of every asset"
  task update_book_value: :environment do
    Asset.all.each do |a|
      a.update_book_value
    end
  end
  desc "Updates the disposition of every asset"
  task update_disposition: :environment do
    Asset.all.each do |a|
      a.record_disposition
    end
  end

  desc "Updates all updateable attributes.  Can accept a sql fragment to restrict"
  task :update_all, [:sql_frag] => [:environment] do |t, args|

    # `rake transam:update_all['organization_id is null']` becomes 
    # Asset.where("organization_id is null")
    if args[:sql_frag]
      asset_set = Asset.where(args[:sql_frag])
    else
      asset_set = Asset.all
    end

    asset_set.each do |a|
      typed_asset = Asset.get_typed_asset(a)
      typed_asset.update_methods.each do |m|
        typed_asset.send(m)
      end
    end
  end
end
