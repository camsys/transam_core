FactoryGirl.define do

  factory :organization_type do
    name 'TestOrg'
    class_name 'TestOrg'
    display_icon_name 'fa fa-bus'
    map_icon_name 'greenIcon'
    description 'Organizations who own, operate, or manage transit assets.'
    active 1
  end

end
