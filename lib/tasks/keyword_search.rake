#full_text_search.rake

namespace :transam_core do

  desc "Index all searchable items"
  task index_all: :environment do
    Asset.all.each do |asset|
      asset.write_to_keyword_search_index
    end
    binding.pry
    Comment.all.each do |comment|
      comment.write_to_keyword_search_index
    end
    Document.all.each do |document|
      document.write_to_keyword_search_index
    end
    Expenditure.all.each do |expenditure|
      expenditure.write_to_keyword_search_index
    end
    Vendor.all.each do |vendor|
      vendor.write_to_keyword_search_index
    end
  end

end