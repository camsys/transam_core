FactoryGirl.define do

  factory :policy_asset_subtype_rule do
    ali_code 'XXXXXXXX'
    max_service_life_months 144
    max_service_life_miles 500000
    replacement_cost 395500
    cost_fy_year 6
    replacement_ali_code 'XXXXXXXX'
    replace_with_new true
    replace_with_leased false
  end
end
