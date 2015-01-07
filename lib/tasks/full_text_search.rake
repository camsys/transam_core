#full_text_search.rake

namespace :transam_core do
  desc "Index assets based on searchable fields list"
  task index_all_assets: :environment do
  	binding.pry
    Asset.all.each do |asset|
      asset.write_to_full_text_search_index(asset.object_key)
    end
  end
end