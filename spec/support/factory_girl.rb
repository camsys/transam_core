RSpec.configure do |config|
  # additional factory_girl configuration

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events asset_subtypes asset_types messages policies policy_items organizations organization_types users]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      #FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
