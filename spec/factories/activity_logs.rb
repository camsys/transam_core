FactoryBot.define do
  factory :activity_log do
    association :user, factory: :normal_user
    organization_id 1
    item_type "Test"
    activity "Test Activity"
    activity_time Time.now
  end
end
