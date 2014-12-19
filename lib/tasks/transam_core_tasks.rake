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
        url = Rails.application.routes.url_helpers.asset_url(asset)
        {:external_id => post.id,
         :fields => [{:name => 'title', :value => post.title, :type => 'string'},
                     {:name => 'body', :value => post.body, :type => 'text'},
                     {:name => 'url', :value => url, :type => 'enum'},
                     {:name => 'created_at', :value => post.created_at.iso8601, :type => 'date'}]}
      end

      results = client.create_or_update_documents(ENV['SWIFTYPE_ENGINE_SLUG'], Asset.model_name.downcase, documents)

      results.each_with_index do |result, index|
        puts "Could not create #{assets[index].title} (##{assets[index].id})" if result == false
      end
    end
  end

end

namespace :test do
  desc "Custom dependency to set test environment"
  task :set_test_env do # Note that we don't load the :environment task dependency
    Rails.env = "test"
  end
end