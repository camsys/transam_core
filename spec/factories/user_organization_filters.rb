FactoryBot.define do
  factory :user_organization_filter do
    sequence(:name) {|n| "Test Filter #{n}"}
    description "Test Filter Description"
    created_by_user_id 1
    query_string "SELECT `organizations`.* FROM `organizations`"
    active true
  end
end
