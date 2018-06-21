FactoryBot.define do

  factory :policy_asset_subtype_rule do
    association :asset_subtype
    min_service_life_months 144
    min_service_life_miles 500000
    replacement_cost 2000
    cost_fy_year { Date.today.month > 6 ? Date.today.year - 1 : Date.today.year - 2 }
    replace_with_new true
    replace_with_leased false
    purchase_replacement_code 'XXX'
    rehabilitation_code 'XXX'
  end
end
