FactoryGirl.define do
  factory :delayed_job_priority do
    sequence :class_name do |n|
      "AssetUpdateJob#{n}"
    end
    priority -10
  end
end
