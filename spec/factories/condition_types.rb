FactoryGirl.define do

  factory :condition_type, :class => :condition_type do
    sequence(:rating) { |n| n }
    sequence(:name) { |n| "name#{n}"}
    sequence(:description) { |n| "description#{n}"}
    active 1
  end
end
