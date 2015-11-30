FactoryGirl.define do
  factory :activity do
    association :organization_type
    name "Test Name"
    description "Test Description"
    start "12/24/20"
    due "12/24/20"
    notify "12/24/20"
    warn "12/24/20"
    alert "12/24/20"
    escalate "12/24/20"
    job_name "ActivityJob"
  end
end
