#full_text_search.rake

namespace :transam_core do

  desc "Index all searchable items"
  task index_all: :environment do
    Asset.all.each do |asset|
      asset.write_to_keyword_search_index
    end
    AssetEvent.all.each do |asset_event|
      asset_event.write_to_keyword_search_index
    end
    ActivityLog.all.each do |activity_log|
      activity_log.write_to_keyword_search_index
    end
  end

  desc "Index assets based on searchable fields list"
  task index_assets: :environment do
    Asset.all.each do |asset|
      asset.write_to_keyword_search_index
    end
  end 

  desc "Index asset events based on searchable fields list"
  task index_asset_events: :environment do
    AssetEvent.all.each do |asset_event|
      asset_event.write_to_keyword_search_index
    end
  end

  desc "Index asset events based on searchable fields list"
  task index_activity_logs: :environment do
    ActivityLog.all.each do |activity_log|
      activity_log.write_to_keyword_search_index
    end
  end

end