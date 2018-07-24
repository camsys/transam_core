FactoryBot.define do

  factory :asset_subtype do
    association :asset_type
    name "Test Asset Subtype"
    description "Test Asset Subtype"
    active true
  end

  factory :equipment_subtype, :class => :asset_subtype do
    association :asset_type, :factory => :equipment_type
    name "Test Equipment Subtype"
    description "Test Equipment Subtype"
    active true
  end

end
