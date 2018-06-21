FactoryBot.define do
  factory :task do
    association :user, factory: :admin
    priority_type_id 1
    association :organization
    subject 'Test Task Subject'
    body 'Test Task Body'
  end
end
