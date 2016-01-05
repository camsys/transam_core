FactoryGirl.define do

  trait :basic_event_traits do
    association :asset, :factory => :equipment_asset
  end

  factory :asset_event do
    basic_event_traits
    asset_event_type_id 1
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
    asset_event_type { AssetEventType.find_by(:class_name => 'DispositionUpdateEvent') }
    disposition_type_id 2
    sales_proceeds 25000
    new_owner_name "Mr Morebucks"
    event_date Date.today
  end

  factory :service_status_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'ServiceStatusUpdateEvent') }
    service_status_type_id 2
    event_date Date.today
  end

  factory :location_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'LocationUpdateEvent') }
    association :parent, :factory => :equipment_asset
  end

  factory :mileage_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'MileageUpdateEvent') }
    current_mileage 100000
  end

  factory :schedule_disposition_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'ScheduleDispositionUpdateEvent') }
    disposition_date Date.today + 8.years
  end

  factory :schedule_rehabilitation_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'ScheduleRehabilitationUpdateEvent') }
  end

  factory :schedule_replacement_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'ScheduleReplacementUpdateEvent') }
    # Note that this can have either a replacement or a rebuild year, but it needs at least one
  end

  factory :rehabilitation_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'RehabilitationUpdateEvent') }
    event_date Date.today
  end

  factory :maintenance_provider_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'MaintenanceProviderUpdateEvent') }
  end

  factory :maintenance_update_event do
    basic_event_traits
    asset_event_type { AssetEventType.find_by(:class_name => 'MaintenanceUpdateEvent') }
  end

end
