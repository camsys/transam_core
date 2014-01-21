namespace :transam do
  desc "Updates the service status and condition of every asset"
  task UpdateAssets: :environment do
    Asset.all.each do |a|
      a.update_service_status
      a.update_condition
    end
  end
end
