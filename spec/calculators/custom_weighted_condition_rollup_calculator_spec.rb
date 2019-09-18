require 'rails_helper'

RSpec.describe CustomWeightedConditionRollupCalculator, :type => :calculator do

  before(:all) do
    @parent_asset = create(:buslike_asset)
    @dependent_asset1 = create(:buslike_asset, :reported_condition_rating => nil, :parent => @parent_asset)
    @dependent_asset2 = create(:buslike_asset, :reported_condition_rating => 4.0, :parent => @parent_asset)
    @dependent_asset3 = create(:buslike_asset, :reported_condition_rating => 5.0, :parent => @parent_asset)
  end

  let(:test_calculator) { CustomWeightedConditionRollupCalculator.new }

  it 'returns nil for no weighted dependents' do
    expect(test_calculator.calculate(@parent_asset)).to be_nil
  end

  it 'calculates sum of weighted ratings divided by sum of weights' do
    @dependent_asset1.update(weight: 2)
    @dependent_asset2.update(weight: 1)
    @dependent_asset3.update(weight: 0)

    expect(test_calculator.calculate(@parent_asset)).to eq(1)
  end
end
