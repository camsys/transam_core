FactoryBot.define do
  factory :document_tag do
    name { "MyString" }
    description { "MyText" }
    pattern { "MyString" }
    allowed_extensions { "MyString" }
    document_folders { nil }
    active { false }
  end
end
