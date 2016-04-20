require 'rails_helper'

RSpec.describe PurchasePricePlusInterestCalculator, :type => :calculator do

  before(:all) do
    @parent_organization = create(:organization_basic)
    @organization = create(:organization_basic)
    @asset_subtype = create(:asset_subtype)
    @parent_policy = create(:policy, :organization => @parent_organization, :parent => nil)
    @policy_asset_subtype_rule = create(:policy_asset_subtype_rule, :asset_subtype => @asset_subtype, :policy => @parent_policy)
    @policy = create(:policy, :organization => @organization, :parent => @parent_policy)
    @policy.policy_asset_subtype_rules << @policy_asset_subtype_rule
  end

  before(:each) do
    @test_asset = create(:buslike_asset_basic_org, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  let(:test_calculator) { PurchasePricePlusInterestCalculator.new }

  it 'no date given use planning year' do
    expect(test_calculator.calculate(@test_asset)).to eq(2205)
  end
  it 'use date given' do
    expect(test_calculator.calculate_on_date(@test_asset, Date.today)).to eq(2100)
  end
end
