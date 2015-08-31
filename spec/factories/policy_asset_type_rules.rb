FactoryGirl.define do

  factory :policy_asset_type_rule do
    service_life_calculation_type_id 1
    replacement_cost_calculation_type_id 1
    annual_inflation_rate 1.05
    pcnt_residual_value 0.05
  end
end
