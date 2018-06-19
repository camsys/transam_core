FactoryBot.define do
  factory :comment do
    association :creator, factory: :normal_user
    comment 'Test Comment'
    commentable_type 'Asset'
  end
end
