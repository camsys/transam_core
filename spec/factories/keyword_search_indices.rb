FactoryBot.define do

  factory :keyword_search_index do
    association :organization
    object_class 'Inventory'
    search_text 'test search'
    context 'test context'
    summary 'test summary'
  end
end
