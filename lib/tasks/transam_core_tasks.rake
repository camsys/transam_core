# desc "Explaining what the task does"
# task :transam_core do
#   # Task goes here
# end
namespace :transam_core do

  desc "Prepare the dummy app for rspec and capybara"
  task :prepare_rspec => ["app:test:set_test_env", :environment] do
    %w(db:drop db:create db:schema:load db:migrate db:seed).each do |cmd|
      puts "Running #{cmd} in Core"
      puts "ENV IS #{Rails.env}"
      Rake::Task[cmd].invoke
    end
  end

  desc "Index all searchable content"
  task :index_searchables => :environment do

    if ENV['SWIFTYPE_API_KEY'].blank?
      abort("SWIFTYPE_API_KEY not set")
    end

    if ENV['SWIFTYPE_ENGINE_SLUG'].blank?
      abort("SWIFTYPE_ENGINE_SLUG not set")
    end

    client = Swiftype::Client.new

    Asset.find_in_batches(:batch_size => 100) do |assets|
      documents = assets.map do |asset|
        url = Rails.application.routes.url_helpers.asset_path(asset)
        {:external_id => asset.id,
         :fields => [{:name => 'object_key', :value => asset.object_key, :type => 'string'},
                     {:name => 'manufacturer_model', :value => asset.manufacturer_model, :type => 'string'},
                     {:name => 'license_plate', :value => asset.license_plate, :type => 'string'}]}
      end

      results = client.create_or_update_documents("engine", "assets", documents)

      results.each_with_index do |result, index|
        puts "Could not create #{assets[index].title} (##{assets[index].id})" if result == false
      end
    end
  end

end

# Code for creating a document type with Swiftype.  
# Convert to rake task if we move forward with product.
# curl -XPOST 'https://api.swiftype.com/api/v1/engines/bookstore/document_types.json' \
#   -H 'Content-Type: application/json' \
#   -d '{
#         "auth_token":"S7wLwDXpRHyj-RJrzqAC",
#         "document_type":{"name":"books"}
#       }'

namespace :test do
  desc "Custom dependency to set test environment"
  task :set_test_env do # Note that we don't load the :environment task dependency
    Rails.env = "test"
  end
end