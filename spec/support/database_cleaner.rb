RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation, {:only => %w[assets asset_events asset_groups asset_groups_assets asset_subtypes asset_types messages notices policies policy_items organizations organization_types users users_organizations]}
  config.before(:suite) do
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
