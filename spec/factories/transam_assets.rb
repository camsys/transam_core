# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do

  sequence :asset_tag do |n|
    "ABS_TAG#{n}"
  end

  trait :basic_asset_attributes do
    asset_tag
    purchase_cost { 2000.0 }
    purchase_date { 1.year.ago }
    in_service_date { 1.year.ago }
    purchased_new { false }
    association :asset_subtype
    association :organization
  end

  factory :buslike_asset, :class => :transam_asset do
    basic_asset_attributes
  end

  factory :equipment_asset, :class => :equipment do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_subtype, :factory => :equipment_subtype
    description { 'equipment test' }
    purchase_cost { 2000.0 }
    quantity { 1 }
    quantity_units { 'piece' }
    expected_useful_life { 120 }
    reported_condition_rating { 2.0 }
  end

end