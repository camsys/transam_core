FactoryGirl.define do

  factory :asset_type do
    name "Vehicle"
    class_name "Vehicle" # For core, no concrete classes exist
    description "Vehicle"
    active true
    display_icon_name "fa fa-bus"
    map_icon_name "redIcon"
  end
end