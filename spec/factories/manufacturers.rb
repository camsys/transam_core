FactoryBot.define do

  factory :manufacturer do
    filter 'vehicle'
    name 'Ford'
    code 'FRD'
    active true
  end

end
