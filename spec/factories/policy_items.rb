FactoryGirl.define do

  factory :policy_item do
    association :asset_subtype
    max_service_life_years 12
    max_service_life_miles 500000
    replacement_cost 395500
    rehabilitation_cost 100000
    rehabilitation_year 6
    extended_service_life_years 4
    extended_service_life_miles 100000
    pcnt_residual_value 0
    active 1
  end
end
