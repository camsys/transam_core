#full_text_search.rake

namespace :transam_core do

  desc "Index assets based on searchable fields list"
  task index_all_assets: :environment do
    Asset.all.each do |asset|
      asset.write_to_keyword_search_index
    end
  end 

  desc "Index asset events based on searchable fields list"
  task index_all_asset_events: :environment do
    AssetEvent.all.each do |asset_event|
      asset_event.write_to_keyword_search_index
    end
  end

end