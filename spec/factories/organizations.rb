FactoryGirl.define do

  factory :organization do
    customer_id 1
    address1 '100 Main St'
    city 'Harrisburg'
    state 'PA'
    zip '17120'
    url 'http://www.example.com'
    phone '9999999999'
    grantor_id 1
    association :organization_type, :factory => :organization_type
    sequence(:name) { |n| "Org #{n}" }
    short_name {name}
    license_holder true
  end

end
