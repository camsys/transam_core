FactoryBot.define do

  sequence :name do |n|
    "NAME#{n}"
  end

  sequence :description do |n|
    "DESCRIPTION#{n}"
  end

  sequence :code do |n|
    "CODE#{n}"
  end

  trait :basic_asset_group_attributes do
    association :organization, :factory => :organization
    name
    description
    code
  end

  factory :asset_group, :class => :asset_group do
    basic_asset_group_attributes
  end

end
