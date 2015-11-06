require 'rails_helper'

RSpec.describe ConditionType, :type => :model do
  it '#max_rating' do
    expect(ConditionType.max_rating.to_i).to eq(5)
  end
  it '#min_rating' do
    expect(ConditionType.min_rating.to_i).to eq(1)
  end
  it '#from_rating' do
    expect(ConditionType.from_rating(1.5)).to eq(ConditionType.find_by(:rating => 1))
    expect(ConditionType.from_rating(2.22)).to eq(ConditionType.find_by(:rating => 2))
    expect(ConditionType.from_rating(3.0)).to eq(ConditionType.find_by(:rating => 3))
    expect(ConditionType.from_rating(4.21)).to eq(ConditionType.find_by(:rating => 4))
    expect(ConditionType.from_rating(4.79)).to eq(ConditionType.find_by(:rating => 4))
    expect(ConditionType.from_rating(4.8)).to eq(ConditionType.find_by(:rating => 5))
    expect(ConditionType.from_rating(4.95)).to eq(ConditionType.find_by(:rating => 5))
    expect(ConditionType.from_rating(5)).to eq(ConditionType.find_by(:rating => 5
    ))
  end

  it '.to_s' do
    expect(ConditionType.first.to_s).to eq(ConditionType.first.name)
  end
end
