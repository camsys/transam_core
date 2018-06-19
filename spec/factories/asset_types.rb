FactoryBot.define do

  factory :asset_type do
    name "Vehicle"
    class_name "Vehicle" # For core, no concrete classes exist
    description "Vehicle"
    active true
    display_icon_name "fa fa-bus"
    map_icon_name "redIcon"
  end

  factory :equipment_type, :class => :asset_type do
    name "Equipment"
    class_name "Equipment"
    description "Equipment"
    active true
    display_icon_name "fa fa-bus"
    map_icon_name "redIcon"
  end
end
