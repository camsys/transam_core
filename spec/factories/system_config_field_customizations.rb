FactoryBot.define do
  factory :system_config_field_customization do
    table_name { "MyString" }
    field_name { "MyString" }
    description { "MyString" }
    is_required { false }
    is_locked { false }
    active { false }
  end
end
