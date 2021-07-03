# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'codacy-coverage'
require 'simplecov'

SimpleCov.formatters = [
  Codacy::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start 'rails' do
  add_group "Calculators", "app/calculators"
  add_group "File Handlers", "app/file_handlers"
  add_group "Reports", "app/reports"
  add_group "Services", "app/services"
  add_group "Searches", "app/searches"
  add_group "Uploaders", "app/uploaders"
end

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'factory_bot_rails'
require 'database_cleaner'
require 'devise'
require 'shoulda-matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[TransamCore::Engine.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include RequestSpecHelper, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    with.library :rails
  end
end

module TransamMapMarkers; end

# declare concrete Organization class for tests
class TestOrg < Organization
  has_many :assets,   :foreign_key => 'organization_id'

  def get_policy
    return Policy.where("`organization_id` = ?",self.id).order('created_at').last
  end
end

#declaring a concrete organization for tests that doesn't ever pull from the database
class StubOrg < Organization
  has_many :assets,   :foreign_key => 'organization_id'

  def get_policy
    return StubPolicy.new(organization: self)
  end
end

class StubPolicy < Policy

  def find_or_create_asset_type_rule a

  end

  def find_or_create_asset_subtype_rule a, b=nil

  end

  def replacement_cost
    100000
  end

  def replacement_cost_calculation_type
    CostCalculationType.first
  end

  def service_life_calculation_type
    ServiceLifeCalculationType.first
  end

  def min_service_life_months
    120
  end

end

# declare concrete Asset class for tests
class Vehicle < Asset
  has_many :mileage_updates
  
  def cost
    purchase_cost
  end
end
