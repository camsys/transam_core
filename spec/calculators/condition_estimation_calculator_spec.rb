require 'rails_helper'

RSpec.describe ConditionEstimationCalculator, :type => :calculator do

  let(:test_calculator) { ConditionEstimationCalculator.new(:policy => build_stubbed(:policy)) }
  let(:test_asset) { build_stubbed(:buslike_asset) }

  describe '#slope' do
    it 'calculates positive slopes' do
      expect(test_calculator.slope(0,0,10,10).round(5)).to eq(1.0)
    end

    it 'calculates negative slope' do
      expect(test_calculator.slope(0,0,10,-10).round(5)).to eq(-1.0)
    end

    it 'returns a float for integer values' do
      expect(test_calculator.slope(0,0,2,1).round(5)).to eq(0.5)
    end

    it 'returns a float for float values' do
      expect(test_calculator.slope(0.0,7.7,1.0,8.7).round(5)).to eq(1.0)
    end

    it 'can handle mixed input types' do
      expect(test_calculator.slope(0,8,1,8.7).round(5)).to eq(0.7)
    end

    it 'calculates the slope of a horizontal line' do
      expect(test_calculator.slope(0,10,10,10).round(5)).to eq(0.0)
    end

    it 'can handle a vertical line' do
      expect(test_calculator.slope(0,10,0,100).round(5)).to eq(-1.0) #HMM
    end

    it 'can handle a single point' do
      expect(test_calculator.slope(1,1,1,1)).to eq(-1) #HMM
    end
  end


end
