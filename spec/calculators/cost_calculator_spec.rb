require 'rails_helper'

RSpec.describe CostCalculator, :type => :calculator do
  let(:policy) { build_stubbed(:policy, nil, nil) }
  let(:test_calculator) { CostCalculator.new }
  let(:test_asset) { build_stubbed(:buslike_asset) }

  describe '.replacement_year' do
    it 'no asset replacement year' do
      test_asset.scheduled_replacement_year = nil
      expect(test_calculator.send(:replacement_year, test_asset)).to eq(test_asset.policy_replacement_year)
    end
    it 'asset replacement year' do
      expect(test_calculator.send(:replacement_year, test_asset)).to eq(test_asset.scheduled_replacement_year)
    end
  end

  describe '.future_cost' do
    it 'calculates correctly' do
      expect(test_calculator.send(:future_cost,100,2,policy.interest_rate).round(4)).to eq(110.25)
    end

    it 'calculates current cost if years is 0' do
      expect(test_calculator.send(:future_cost,100,0,policy.interest_rate).round(4)).to eq(100.0)
    end

    it 'can handle fractions of years' do
      expect(test_calculator.send(:future_cost,100,1.02,policy.interest_rate).round(4)).to eq(105.1025)
    end
  end

end
