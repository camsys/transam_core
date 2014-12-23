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

    puts "Processing Assets"

    asset_array = []

    Asset.limit(250) do |assets|
      documents = assets.map do |asset|

        url = Rails.application.routes.url_helpers.asset_path(asset)

        #puts asset.to_yaml
        
        asset.attributes.each { |asset_attribute|

            asset_hash = {}
            
            if asset_attribute[1].present?
              asset_hash["name"] = asset_attribute[0]
              asset_hash["value"] = asset_attribute[1].to_s
              asset_hash["type"] = "string"
              asset_array.push(asset_hash)
            else
              puts "Blank attribute?  To_Yaml:" + asset_attribute.to_yaml
            end
        }

        {
          :external_id => asset.id,
          :fields => asset_array[1..200]
        }
         # :fields => [{:name => 'object_key', :value => asset.object_key, :type => 'string'},
         #             {:name => 'asset_tag', :value => asset.asset_tag, :type => 'string'},
         #             {:name => 'agency', :value => asset.agency, :type => 'string'},
         #             {:name => 'manufacturer_model', :value => asset.manufacturer_model, :type => 'string'},
         #             {:name => 'in_service', :value => asset.in_service_date, :type => 'string'},
         #             {:name => 'license_plate', :value => asset.license_plate, :type => 'string'}]}
      end

      binding.pry

      results = client.create_or_update_documents("engine", "assets", documents)

      results.each_with_index do |result, index|
        puts "Could not create #{assets[index].asset_tag} (##{assets[index].id})" if result == false
      end

    end

    puts "Processing asset events."

    asset_event_array = []

    AssetEvent.limit(750) do |asset_events|

        documents = asset_events.map do |asset_event|

        asset_event_hash = {}
        asset_event
        asset_event = AssetEvent.as_typed_event(asset_event)

        asset_event.attributes.each { |asset_event_attribute|

          puts asset_event_attribute.to_yaml
          if asset_event_attribute[1].present?
            asset_event_hash["name"] = asset_event_attribute[0]
            asset_event_hash["value"] = asset_event_attribute[1].to_s
            asset_event_hash["type"] = "string"
            asset_event_array.push(asset_event_hash)
          else
              puts "Blank attribute?  To_Yaml:" + asset_attribute.to_yaml
          end
        }
        #url = Rails.application.routes.url_helpers.inventory_asset_event_path(asset_event) if asset_event["id"].present?

        {:external_id => asset_event.id,
         :fields => asset_event_array[1..200]
        }
    end

      binding.pry

      results = client.create_or_update_documents("engine", "asset_event", documents)

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