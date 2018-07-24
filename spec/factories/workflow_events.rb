FactoryBot.define do
  factory :workflow_event do
    event_type 'Test Event'
    creator { FactoryBot.create(:normal_user) }
  end
end
