FactoryGirl.define do
  factory :activity_log do
    association :user, factory: :normal_user
    organization User.last.organization rescue Rails.logger.info "ERROR: No seed data."
    item_type "Test"
    activity "Test Activity"
    activity_time Time.now
  end
end
