FactoryGirl.define do

  factory :test_condition_update_event, :class => :condition_update_event do
    assessed_rating 2.0
    current_mileage 300000
    event_date Date.today
  end
end
