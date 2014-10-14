FactoryGirl.define do

  factory :policy do
    association :organization, :factory => :organization
    interest_rate "0.05"
    depreciation_calculation_type_id 1
    service_life_calculation_type_id 1
    cost_calculation_type_id 1
    condition_estimation_type_id 1
    condition_threshold 2.5
    name 'TestPolicy'
    description 'Test Policy'
  end
end
