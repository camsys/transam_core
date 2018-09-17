# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :notice, :aliases => [:system_notice] do
    subject { "Test Subject" }
    summary { "Test Summary" }
    details { "Test Details" }
    association :notice_type, :factory => :notice_type
    active { true }
    organization { nil }
  end

  factory :notice_type do
    active { true }
    name { 'System Notice' }
    description { 'System notices.' }
    display_icon { 'fa-warning' }
    display_class { 'text-danger' }
  end
end
