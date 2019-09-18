require 'rails_helper'

RSpec.describe MedianConditionRollupCalculator, :type => :calculator do

  before(:each) do
    @parent_asset = create(:buslike_asset)
    @dependent_asset1 = create(:buslike_asset, :reported_condition_rating => 1.0)
    @dependent_asset2 = create(:buslike_asset, :reported_condition_rating => 4.0)
    @dependent_asset3 = create(:buslike_asset, :reported_condition_rating => 5.0)
  end

  let(:test_calculator) { MedianConditionRollupCalculator.new }

  it 'returns nil for no ratings' do
    expect(test_calculator.calculate(@parent_asset)).to be_nil
  end

  it 'gets median condition of dependents' do
    [@dependent_asset1, @dependent_asset2, @dependent_asset3].each do |a|
      a.update(parent: @parent_asset)
    end
    expect(test_calculator.calculate(@parent_asset)).to eq(4.0)
  end
end
