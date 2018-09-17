#full_text_search.rake

namespace :transam do

  namespace :keyword_search do

    desc "Index all searchable items"
    task index_all: :environment do
      Rails.logger.info "Starting Keyword Search Index"
      KeywordSearchIndex.delete_all
      Rails.application.config.transam_keyword_searchable_classes.each do |klass|
        if klass.class.to_s == 'String'
          klass = klass.constantize
        end

        Rails.logger.info "Creating keyword index for #{klass}"
        klass.all.find_each do |obj|
          obj.write_to_index
        end
      end
    end

  end

end
