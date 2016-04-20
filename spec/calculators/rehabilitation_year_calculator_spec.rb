require 'rails_helper'

RSpec.describe RehabilitationYearCalculator, :type => :calculator do

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
    @test_asset = create(:buslike_asset, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  let(:test_calculator) { RehabilitationYearCalculator.new }

  it 'no service months' do
    expect(test_calculator.calculate(@test_asset)).to be nil
  end

  it 'service months' do
    PolicyAssetSubtypeRule.find_by(:policy => @policy, :asset_subtype => @test_asset.asset_subtype).update!(:rehabilitation_service_month => 12)

    in_service_date_fy = @test_asset.in_service_date.month < 7 ? @test_asset.in_service_date.year - 1 : @test_asset.in_service_date.year

    expect(test_calculator.calculate(@test_asset)).to eq(in_service_date_fy + 1)
  end

end
