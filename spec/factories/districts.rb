FactoryBot.define do

  factory :district do
    district_type_id { 1 }
    name { 'Test District' }
    code { 'DIS' }
    description { 'Test District description' }
    active { true }
  end

end
