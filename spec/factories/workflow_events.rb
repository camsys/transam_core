FactoryGirl.define do
  factory :workflow_event do
    event_type 'Test Event'
    creator { FactoryGirl.create(:normal_user) }
  end
end
