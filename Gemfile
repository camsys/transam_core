source "https://rubygems.org"

# Declare your gem's dependencies in leaflet_gem.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'byebug'
gem 'countries', "~> 0.11.5"  # lock gem for dummy app
gem 'mysql2', "~> 0.5.1" # lock gem for dummy app
gem "capybara", '2.6.2' # lock gem for old capybara behavior on hidden element xpath
gem 'ckeditor', '4.3.0'
gem 'rack-test'
gem 'sass-rails'
gem 'rails-controller-testing' # assigns has been extracted to this gem
gem 'awesome_print'
gem 'responders' # get jbuilder working on Travis. It wasn't automatically rendering the json views.
gem 'sprockets', '3.7.2' # lock sprockets to 3 because bootstrap-editable-rails is not compatible with 4

gem 'active_record-acts_as', git: 'https://github.com/camsys/active_record-acts_as', branch: 'master' # use our fork