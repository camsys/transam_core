FactoryBot.define do
  factory :activity do
    name "Test Name"
    description "Test Description"
    frequency_type_id 1
    job_name "ActivityJob"
    execution_time 'one hour'
  end
end
