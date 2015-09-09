FactoryGirl.define do
  factory :comment do
    association :creator, factory: :normal_user
    comment 'Test Comment'
    commentable_type 'Test Type'
  end
end
