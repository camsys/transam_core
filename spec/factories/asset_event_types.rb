FactoryGirl.define do

  factory :asset_event_type do
    name "Update the mileage"
    class_name "MileageUpdateEvent"
    job_name "AssetMileageUpdateJob"
    display_icon_name "fa fa-road"
    description "Mileage Update"
    active true
  end
end
