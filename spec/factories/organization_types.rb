FactoryGirl.define do

  factory :organization_type do
    name 'TestOrg'
    class_name 'Organization'
    display_icon_name 'fa travelcon-bus'
    map_icon_name 'greenIcon'
    description 'Organizations who own, operate, or manage transit assets.'
    active 1
  end

end
