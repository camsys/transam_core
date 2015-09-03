FactoryGirl.define do

  factory :policy_asset_subtype_rule do
    min_service_life_months 144
    min_service_life_miles 500000
    replacement_cost 395500
    cost_fy_year 6
    replace_with_new true
    replace_with_leased false
  end
end
