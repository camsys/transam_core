FactoryBot.define do

  trait :policy_asset_subtype_rule_attributes do
    min_service_life_months { 144 }
    min_service_life_miles { 500000 }
    replacement_cost { 2000 }
    cost_fy_year { Date.today.month > 6 ? Date.today.year - 1 : Date.today.year - 2 }
    replace_with_new { true }
    replace_with_leased { false }
    purchase_replacement_code { 'XXX' }
    rehabilitation_code { 'XXX' }
  end

  factory :policy_asset_subtype_rule do
    policy_asset_subtype_rule_attributes
    association :asset_subtype
  end

  factory :policy_transam_asset_subtype_rule, :class => :policy_asset_subtype_rule do
    policy_asset_subtype_rule_attributes
    default_rule { true }

    trait :fuel_type do
      fuel_type_id { 18 }
    end
  end
end
