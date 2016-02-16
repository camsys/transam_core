require 'rails_helper'

RSpec.describe PolicyAssetTypeRule, :type => :model do

  let(:test_rule) { create(:policy_asset_type_rule, :policy => create(:policy)) }


  describe 'associations' do
    it 'belongs to a policy' do
      expect(test_rule).to belong_to(:policy)
    end
    it 'belongs to an asset type' do
      expect(test_rule).to belong_to(:asset_type)
    end
    it 'has a service life calculator' do
      expect(test_rule).to belong_to(:service_life_calculation_type)
    end
    it 'has a replacement cost calculator' do
      expect(test_rule).to belong_to(:replacement_cost_calculation_type)
    end
  end
  describe 'validations' do
    it 'must have a policy' do
      test_rule.policy = nil
      expect(test_rule.valid?).to be false
    end
    it 'must have an asset type' do
      test_rule.asset_type = nil
      expect(test_rule.valid?).to be false
    end
    it 'must have a service life calculator' do
      test_rule.service_life_calculation_type = nil
      expect(test_rule.valid?).to be false
    end
    it 'must have a replacement cost calculator' do
      test_rule.replacement_cost_calculation_type = nil
      expect(test_rule.valid?).to be false
    end
    describe 'annual inflation rate' do
      it 'must exist' do
        test_rule.annual_inflation_rate = nil
        expect(test_rule.valid?).to be false
      end
      it 'must be a number' do
        test_rule.annual_inflation_rate = 'abc'
        expect(test_rule.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(PolicyAssetTypeRule.allowable_params).to eq([
      :id,
      :policy_id,
      :asset_type_id,
      :service_life_calculation_type_id,
      :replacement_cost_calculation_type_id,
      :annual_inflation_rate,
      :pcnt_residual_value
    ])
  end

  it '.to_s' do
    expect(test_rule.to_s).to eq(test_rule.asset_type.to_s)
  end
  it '.name' do
    expect(test_rule.name).to eq("Policy Rule #{test_rule.asset_type}")
  end

  it '.set_defaults' do
    test_rule = PolicyAssetTypeRule.new
    expect(test_rule.annual_inflation_rate).to eq(1.1)
    expect(test_rule.pcnt_residual_value).to eq(0)
  end
end
