require 'rails_helper'

RSpec.describe WeightedAverageConditionRollupCalculator, :type => :calculator do

  before(:all) do
    @parent_asset = create(:buslike_asset)
    @dependent_asset1 = create(:buslike_asset, :reported_condition_rating => nil, :parent => @parent_asset)
    @dependent_asset2 = create(:buslike_asset, :reported_condition_rating => 4.0, :parent => @parent_asset)
    @dependent_asset3 = create(:buslike_asset, :reported_condition_rating => 5.0, :parent => @parent_asset)
  end

  let(:test_calculator) { WeightedAverageConditionRollupCalculator.new }

  it 'returns nil for no weighted dependents' do
    expect(test_calculator.calculate(@parent_asset)).to be_nil
  end

  it 'calculates rating weighted by replacement cost' do
    @dependent_asset1.update(scheduled_replacement_cost: 50000)
    @dependent_asset2.update(scheduled_replacement_cost: 100000)
    @dependent_asset3.update(scheduled_replacement_cost: 12000)

    expect(test_calculator.calculate(@parent_asset)).to eq(3)
  end
end