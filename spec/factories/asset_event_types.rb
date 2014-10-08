FactoryGirl.define do

  factory :asset_event_type do
    name "Mileage"
    class_name "Mileage"
    job_name "Mileage"
    display_icon_name "fa fa-road"
    description "Mileage"
    active true
  end
end
