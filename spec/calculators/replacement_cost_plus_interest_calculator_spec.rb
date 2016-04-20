require 'rails_helper'

RSpec.describe ReplacementCostPlusInterestCalculator, :type => :calculator do

  before(:each) do
    @asset_subtype = create(:asset_subtype)
    @parent_organization = create(:organization_basic)
    @organization = create(:organization_basic)

    @parent_policy = create(:policy, :organization => @parent_organization, :parent => nil)
    @policy_asset_subtype_rule = create(:policy_asset_subtype_rule, :asset_subtype => @asset_subtype, :policy => @parent_policy)
    @policy = create(:policy, :organization => @organization, :parent => @parent_policy)
    @policy.policy_asset_subtype_rules << @policy_asset_subtype_rule

    @test_asset = create(:buslike_asset_basic_org, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)

    @condition_update_event = ConditionUpdateEvent.create(:asset => @test_asset)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  let(:test_calculator) { ReplacementCostPlusInterestCalculator.new }

  it 'planning year' do
    expect(test_calculator.calculate(@test_asset)).to eq(2205)
  end
  it 'use date given' do
    expect(test_calculator.calculate_on_date(@test_asset, Date.today+4.years).round(4)).to eq(2552.5631)
  end


end
