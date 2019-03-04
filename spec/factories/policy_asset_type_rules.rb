FactoryBot.define do

  trait :policy_asset_type_rule_attributes do
    service_life_calculation_type_id { 1 }
    replacement_cost_calculation_type_id { 1 }
    annual_inflation_rate { 5.0 }
    pcnt_residual_value { 0.05 }
  end

  factory :policy_asset_type_rule do
    policy_asset_type_rule_attributes
    association :asset_type
  end

  factory :policy_transam_asset_type_rule, :class => :policy_asset_type_rule do
    policy_asset_type_rule_attributes
  end
end
