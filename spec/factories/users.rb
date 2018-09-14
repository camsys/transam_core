# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do

  factory :user do
    phone { 999999999 }
    password { 'Welcome1' }
    association :organization, :factory => :organization
    active { true }

    factory :guest do
      first_name { "bob" }
      last_name  { "guest" }
      sequence(:email) {|n| "bob#{n}@example.com"}

      after(:create) do |u|
        u.add_role :guest
      end
    end

    factory :normal_user do
      first_name { "joe" }
      last_name  { "normal" }
      sequence(:email) {|n| "joe#{n}@example.com"}

      after(:create) do |u|
        u.add_role :user
      end
    end

    factory :manager do
      first_name { "kate" }
      last_name  { "manager" }
      sequence(:email) {|n| "kate#{n}@example.com"}

      after(:create) do |u|
        u.add_role :manager
      end
    end

    factory :admin do
      first_name { "jill" }
      last_name  { "admin" }
      sequence(:email) {|n| "jill#{n}@example.com"}

      after(:create) do |u|
        u.add_role :admin
      end
    end

    factory :technical_contact do
      first_name { "tom" }
      last_name  { "technical" }
      sequence(:email) {|n| "tom#{n}@example.com"}

      after(:create) do |u|
        u.add_role :technical_contact
      end
    end

    after(:create) do |u|
      test_filter = create(:user_organization_filter)
      u.user_organization_filter = test_filter
      u.user_organization_filters << test_filter
      u.save!
    end
  end

end
