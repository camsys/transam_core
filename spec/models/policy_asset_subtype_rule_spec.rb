require 'rails_helper'

RSpec.describe PolicyAssetSubtypeRule, :type => :model do

  let(:test_rule) { create(:policy_asset_subtype_rule, :policy => create(:policy)) }

  describe 'associations' do
    it 'has a policy' do
      expect(test_rule).to belong_to(:policy)
    end
    it 'has an asset subtype' do
      expect(test_rule).to belong_to(:asset_subtype)
    end
    it 'can replace an asset subtype' do
      expect(test_rule).to belong_to(:replace_asset_subtype)
    end
  end
  describe 'validations' do
    it 'must have a policy' do
      test_rule.policy = nil
      expect(test_rule.valid?).to be false
    end
    it 'must have an asset subtype' do
      test_rule.asset_subtype = nil
      expect(test_rule.valid?).to be false
    end

    describe '.min_allowable_policy_values' do
      it 'no parent' do
        expect(test_rule.policy.parent).to be nil
        expect(test_rule.valid?).to be true
      end
      it 'no parent rule' do
        test_rule.policy.update!(:parent => create(:policy))
        expect(test_rule.valid?).to be true
      end
      it 'parent rule min' do
        test_rule.policy.update!(:parent => create(:policy))
        create(:policy_asset_subtype_rule, :policy => test_rule.policy.parent, :asset_subtype => test_rule.asset_subtype, :min_service_life_months => 123)

        test_rule.min_service_life_months = 144
        expect(test_rule.valid?).to be true

        test_rule.min_service_life_months = 120
        expect(test_rule.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(PolicyAssetSubtypeRule.allowable_params).to eq([
      :id,
      :policy_id,
      :asset_subtype_id,
      :min_service_life_months,
      :replacement_cost,
      :cost_fy_year,
      :replace_with_new,
      :replace_with_leased,
      :replace_asset_subtype_id,
      :replacement_cost,
      :lease_length_months,

      :rehabilitation_service_month,
      :rehabilitation_labor_cost,
      :rehabilitation_parts_cost,
      :extended_service_life_months,

      :min_used_purchase_service_life_months
    ])
  end

  it '.to_s' do
    expect(test_rule.to_s).to eq("#{test_rule.asset_subtype.asset_type}: #{test_rule.asset_subtype}")
  end
  it '.name' do
    expect(test_rule.name).to eq("Policy Rule #{test_rule.asset_subtype}")
  end

  it '.total_rehabilitation_cost' do
    test_rule.update!(:rehabilitation_labor_cost => 13, :rehabilitation_parts_cost => 17)

    expect(test_rule.total_rehabilitation_cost).to eq(30)
  end
  describe '.minimum_value' do
    it 'no parent' do
      expect(test_rule.minimum_value('min_service_life_months')).to eq(0)
    end
    it 'no parent rule' do
      test_rule.policy.update!(:parent => create(:policy))
      expect(test_rule.minimum_value('min_service_life_months')).to eq(0)
    end
    it 'min is parent rule' do
      test_rule.policy.update!(:parent => create(:policy))
      create(:policy_asset_subtype_rule, :policy => test_rule.policy.parent, :asset_subtype => test_rule.asset_subtype, :min_service_life_months => 123)
      expect(test_rule.minimum_value('min_service_life_months')).to eq(123)
    end
  end

  it '.set_defaults' do
    test_rule = PolicyAssetSubtypeRule.new

    expect(test_rule.min_service_life_months).to eq(0)
    expect(test_rule.replacement_cost).to eq(0)
    expect(test_rule.lease_length_months).to eq(0)
    expect(test_rule.rehabilitation_service_month).to eq(0)
    expect(test_rule.rehabilitation_labor_cost).to eq(0)
    expect(test_rule.rehabilitation_parts_cost).to eq(0)
    expect(test_rule.extended_service_life_months).to eq(0)
    expect(test_rule.min_used_purchase_service_life_months).to eq(0)
    expect(test_rule.cost_fy_year).to eq(Date.today.month > 6 ? Date.today.year+1 : Date.today.year)
  end
end
