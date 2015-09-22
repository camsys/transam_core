FactoryGirl.define do

  factory :asset_event, :class => :asset_event do
    asset_event_type_id 1
    association :asset, :factory => :buslike_asset
  end

end
