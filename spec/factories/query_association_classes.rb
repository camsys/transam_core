FactoryBot.define do
  factory :query_association_class do
    table_name { "MyString" }
    association_join { "MyText" }
    display_field_name { "MyString" }
    id_field_name { "MyString" }
  end
end
