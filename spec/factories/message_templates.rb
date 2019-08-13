FactoryBot.define do
  factory :message_template do
    name { "MyString" }
    subject { "MyString" }
    description { "MyText" }
    active { false }
    email_enabled { false }
    body { "MyText" }
    priority_type { nil }
  end
end
