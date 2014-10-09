FactoryGirl.define do

  trait :basic_asset_event_attributes do
    association :asset_event_type, :factory => :asset_event_type
    association :asset, :factory => :buslike_asset
  end

  factory :asset_event, :class => :asset_event do
    basic_asset_event_attributes
  end

end
