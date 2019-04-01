require 'rails_helper'

RSpec.describe ConditionType, :type => :model do
  it '#max_rating' do
    expect(ConditionType.max_rating.to_i).to eq(5)
  end
  it '#min_rating' do
    expect(ConditionType.min_rating.to_i).to eq(0)
  end
  it '#from_rating' do
    expect(ConditionType.from_rating(1.5)).to eq(ConditionType.find_by(:rating_ceiling => 1.94))
    expect(ConditionType.from_rating(2.22)).to eq(ConditionType.find_by(:rating_ceiling => 2.94))
    expect(ConditionType.from_rating(3.0)).to eq(ConditionType.find_by(:rating_ceiling => 3.94))
    expect(ConditionType.from_rating(4.21)).to eq(ConditionType.find_by(:rating_ceiling => 4.74))
    expect(ConditionType.from_rating(4.79)).to eq(ConditionType.find_by(:rating_ceiling => 5.00))
    expect(ConditionType.from_rating(4.8)).to eq(ConditionType.find_by(:rating_ceiling => 5.00))
    expect(ConditionType.from_rating(4.95)).to eq(ConditionType.find_by(:rating_ceiling => 5.00))
    expect(ConditionType.from_rating(5)).to eq(ConditionType.find_by(:rating_ceiling => 5.00
    ))
  end

  it '.to_s' do
    expect(ConditionType.first.to_s).to eq(ConditionType.first.name)
  end
end
