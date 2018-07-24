FactoryBot.define do
  factory :asset_event_asset_subsystem do
    association :rehabilitation_update_event
    association :asset_subsystem
  end
end
