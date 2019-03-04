# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do

  sequence :asset_tag do |n|
    "ABS_TAG#{n}"
  end

  trait :basic_asset_attributes do
    association :organization, :factory => :organization
    asset_tag
    purchase_date { 1.year.ago }
    manufacture_year { "2000" }
    in_service_date { Date.new(2001,1,1) }
    created_by_id { 1 }
  end

  factory :buslike_asset, :class => :asset do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_type
    association :asset_subtype
    purchase_cost { 2000.0 }
    expected_useful_life { 120 }
    reported_condition_rating { 2.0 }
  end

  factory :transam_asset do
    asset_tag
    purchase_cost { 2000.0 }
    purchase_date { 1.year.ago }
    in_service_date { 1.year.ago }
    purchased_new { false }
    association :asset_subtype
    association :organization, :factory => :organization_basic
  end

  factory :buslike_asset_basic_org, :class => :asset do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_type
    association :asset_subtype
    purchase_cost { 2000.0 }
    expected_useful_life { 120 }
    reported_condition_rating { 2.0 }
    association :organization, :factory => :organization_basic
  end

  factory :equipment_asset, :class => :equipment do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_type, :factory => :equipment_type
    association :asset_subtype, :factory => :equipment_subtype
    description { 'equipment test' }
    purchase_cost { 2000.0 }
    quantity { 1 }
    quantity_units { 'piece' }
    expected_useful_life { 120 }
    reported_condition_rating { 2.0 }
  end

  factory :equipment_asset_basic_org, :class => :equipment do # An untyped asset which looks like a bus
    basic_asset_attributes
    association :asset_type, :factory => :equipment_type
    association :asset_subtype, :factory => :equipment_subtype
    description { 'equipment test' }
    purchase_cost { 2000.0 }
    quantity { 1 }
    quantity_units { 'piece' }
    expected_useful_life { 120 }
    reported_condition_rating { 2.0 }
    association :organization, :factory => :organization_basic
  end

end
