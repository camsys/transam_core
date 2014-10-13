FactoryGirl.define do

  factory :asset_subtype do
    association :asset_type
    name "Test Asset Subtype"
    description "Test Asset Subtype"
  end

end
