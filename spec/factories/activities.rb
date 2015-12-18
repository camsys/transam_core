FactoryGirl.define do
  factory :activity do
    name "Test Name"
    description "Test Description"
    association :frequency_type
    job_name "ActivityJob"
    execution_time 'one hour'
  end
end
