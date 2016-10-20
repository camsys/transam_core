FactoryGirl.define do
  factory :user_organization_filter do
    sequence(:name) {|n| "Test Filter #{n}"}
    description "Test Filter Description"
    created_by_user_id 1
    active true

    after(:create) do |filter|
      filter.organizations << create(:organization)
      filter.users << create(:normal_user)
      filter.save!
    end
  end
end
