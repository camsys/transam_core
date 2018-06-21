FactoryBot.define do
  factory :form do
    name 'Test Form'
    description 'test form description'
    roles 'admin,manager'
    controller 'test_forms'
    active true
  end
end
