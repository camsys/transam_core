# desc "Explaining what the task does"
# task :transam_core do
#   # Task goes here
# end
desc "Prepare the dummy app for rspec and capybara"
task :prepare_rspec => ["app:test:set_test_env", :environment] do
  Rake::Task["db:create"].invoke
  Rake::Task["db:reset"].invoke
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:seed"].invoke
end

namespace :test do
  desc "Custom dependency to set test environment"
  task :set_test_env do # Note that we don't load the :environment task dependency
    Rails.env = "test"
  end
end