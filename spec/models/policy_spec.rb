require 'rails_helper'

RSpec.describe Policy, :type => :model do

  let(:test_policy) { create(:policy) }

  describe 'associations' do
    it 'has an org' do
      expect(test_policy).to belong_to(:organization)
    end
    it 'has a parent' do
      expect(test_policy).to belong_to(:parent)
    end
    it 'has a condition estimation type' do
      expect(test_policy).to belong_to(:condition_estimation_type)
    end
    it 'has asset type rules' do
      expect(test_policy).to have_many(:policy_asset_type_rules)
    end
    it 'has asset subtype rules' do
      expect(test_policy).to have_many(:policy_asset_subtype_rules)
    end
  end
  describe 'validations' do
    it 'must have an org' do
      test_policy.organization = nil
      expect(test_policy.valid?).to be false
    end
    it 'must have a description' do
      test_policy.description = nil
      expect(test_policy.valid?).to be false
    end
    it 'must have a condition estimation type' do
      test_policy.condition_estimation_type = nil
      expect(test_policy.valid?).to be false
    end
    describe 'condition threshold' do
      it 'must be within range' do
        test_policy.condition_threshold = 6
        expect(test_policy.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(Policy.allowable_params).to eq([
    :organization_id,
    :description,
    :condition_estimation_type_id,
    :condition_threshold,
    :active
  ])
  end

  it '.name' do
    expect(test_policy.name).to eq("#{test_policy.organization.short_name} Policy")
  end
  it '.to_s' do
    expect(test_policy.to_s).to eq(test_policy.name)
  end

  it '.asset_type_rule?' do
    test_rule = create(:policy_asset_type_rule, :policy => create(:policy))
    expect(test_policy.asset_type_rule? test_rule.asset_type).to be false
    test_rule.update!(:policy => test_policy)
    expect(test_policy.asset_type_rule? test_rule.asset_type).to be true
  end
  it '.asset_type_rule' do
    test_rule = create(:policy_asset_type_rule, :policy => create(:policy))
    expect(test_policy.asset_type_rule test_rule.asset_type).to be nil
    test_rule.update!(:policy => test_policy)
    expect(test_policy.asset_type_rule test_rule.asset_type).to eq(test_rule)
  end
  it '.asset_subtype_rule?' do
    test_rule = create(:policy_asset_subtype_rule, :policy => create(:policy))
    expect(test_policy.asset_subtype_rule? test_rule.asset_subtype).to be false
    test_rule.update!(:policy => test_policy)
    expect(test_policy.asset_subtype_rule? test_rule.asset_subtype).to be true
  end
  it '.asset_subtype_rule' do
    test_rule = create(:policy_asset_subtype_rule, :policy => create(:policy))
    expect(test_policy.asset_subtype_rule test_rule.asset_subtype).to be nil
    test_rule.update!(:policy => test_policy)
    expect(test_policy.asset_subtype_rule test_rule.asset_subtype).to eq(test_rule)
  end

  describe'.find_or_create_asset_type_rule' do
    it 'rule already exists' do
      test_rule = create(:policy_asset_type_rule, :policy => test_policy)

      expect(test_policy.find_or_create_asset_type_rule test_rule.asset_type).to eq(test_rule)
    end
    it 'create from parent' do
      expect(test_policy.policy_asset_type_rules.count).to eq(0)
      test_policy.update!(:parent => create(:policy))
      test_rule = create(:policy_asset_type_rule, :policy => test_policy.parent)

      expect(test_policy.find_or_create_asset_type_rule test_rule.asset_type).to eq(test_policy.asset_type_rule test_rule.asset_type)
      expect(test_policy.policy_asset_type_rules.count).to eq(1)
    end
    describe 'no rule' do
      it 'parent has no rule' do
        test_type = create(:asset_subtype)
        test_policy.update!(:parent => create(:policy))

        expect{test_policy.find_or_create_asset_type_rule test_type}.to raise_error(RuntimeError, "Rule for asset type #{test_type} was not found in the parent policy.")
      end
      it 'policy is top level' do
        expect{test_policy.find_or_create_asset_type_rule create(:asset_type)}.to raise_error(RuntimeError, "Policy is a top level policy")
      end
    end
  end
  describe '.find_or_create_asset_subtype_rule' do
    it 'rule already exists' do
      test_rule = create(:policy_asset_subtype_rule, :policy => test_policy)

      expect(test_policy.find_or_create_asset_subtype_rule test_rule.asset_subtype).to eq(test_rule)
    end
    it 'create from parent' do
      expect(test_policy.policy_asset_subtype_rules.count).to eq(0)
      test_policy.update!(:parent => create(:policy))
      test_rule = create(:policy_asset_subtype_rule, :policy => test_policy.parent, :default_rule => true)

      expect(test_policy.find_or_create_asset_subtype_rule test_rule.asset_subtype).to eq(test_policy.asset_subtype_rule test_rule.asset_subtype)
      expect(test_policy.policy_asset_subtype_rules.count).to eq(1)
    end
    describe 'no rule' do
      it 'parent has no rule' do
        test_subtype = create(:asset_subtype)
        test_policy.update!(:parent => create(:policy))

        expect{test_policy.find_or_create_asset_subtype_rule test_subtype}.to raise_error(RuntimeError, "Rule for asset subtype #{test_subtype} was not found in the parent policy.")
      end
      it 'policy is top level' do
        expect{test_policy.find_or_create_asset_subtype_rule create(:asset_subtype)}.to raise_error(RuntimeError, "Policy is a top level policy.")
      end
    end
  end

  it '.set_defaults' do
    expect(Policy.new.condition_threshold).to eq(2.5)
  end
end
