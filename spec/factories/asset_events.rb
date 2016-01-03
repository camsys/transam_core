FactoryGirl.define do

  trait :basic_event_traits do
    association :asset, :factory => :equipment_asset
  end

  factory :asset_event do
    basic_event_traits
    asset_event_type_id 1
  end

  factory :condition_update_like_event, :class => :asset_event do
    basic_event_traits
    condition_type { ConditionType.find_by(:name => "Adequate") }
    assessed_rating 3
    event_date "2014-01-01 12:00:00"
    current_mileage 25000
  end

  factory :condition_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'ConditionUpdateEvent') }
    condition_type_id { ConditionType.find_by(:name => "Adequate").id }
    assessed_rating 2.0
    event_date Date.today
    current_mileage 300000
  end

  factory :disposition_update_event do
    basic_event_traits
    disposition_type_id 2
    sales_proceeds 25000
    new_owner_name "Mr Morebucks"
    event_date Date.today
  end

  factory :service_status_update_event do
    basic_event_traits
    service_status_type_id 2
    event_date Date.today
  end

  factory :location_update_event do
    basic_event_traits
    association :parent, :factory => :equipment_asset
  end

  factory :mileage_update_event do
    basic_event_traits
    current_mileage 100000
  end

  factory :schedule_disposition_update_event do
    basic_event_traits
    disposition_date Date.today + 8.years
  end

  factory :schedule_rehabilitation_update_event do
    basic_event_traits
  end

  factory :schedule_replacement_update_event do
    basic_event_traits
    # Note that this can have either a replacement or a rebuild year, but it needs at least one
  end

  factory :rehabilitation_update_event do
    basic_event_traits
    event_date Date.today
  end

end
