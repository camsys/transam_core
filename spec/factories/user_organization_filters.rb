FactoryGirl.define do
  factory :user_organization_filter do
    sequence(:name) {|n| "Test Filter #{n}"}
    description "Test Filter Description"
    active true
    association :user, :factory => :normal_user

    after(:create) do |filter|
      filter.organizations << create(:organization)
      filter.save!
    end
  end
end
