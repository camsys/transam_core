FactoryBot.define do

  factory :organization, :class => :organization do
    customer_id { 1 }
    address1 { '100 Main St' }
    city { 'Harrisburg' }
    state { 'PA' }
    zip { '17120' }
    url { 'http://www.example.com' }
    phone { '9999999999' }
    association :organization_type, :factory => :stub_organization_type
    sequence(:name) { |n| "Org#{n}" }
    short_name {name}
    license_holder { true }
  end

  factory :organization_basic, :class => :organization do #TODO change this to OrgOriginal
    customer_id { 1 }
    address1 { '100 Main St' }
    city { 'Harrisburg' }
    state { 'PA' }
    zip { '17120' }
    url { 'http://www.example.com' }
    phone { '9999999999' }
    association :organization_type, :factory => :organization_type
    sequence(:name) { |n| "Org#{n+100}" } #TODO change this to OrgOriginal
    short_name {name}
    license_holder { true }
  end

end
