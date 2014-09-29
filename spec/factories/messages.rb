# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    organization
    association :user, :factory => :normal_user
    association :to_user, :factory => :manager
    priority_type_id 3
    subject "Test Email Subject"
    body    "Test Email Body"
  end
end