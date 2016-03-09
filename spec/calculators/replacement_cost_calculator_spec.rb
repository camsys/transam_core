require 'rails_helper'

RSpec.describe ReplacementCostCalculator, :type => :calculator do

  before(:all) do
    @organization = create(:organization)
    @asset_subtype = create(:asset_subtype)
    @policy = create(:policy, :organization => @organization)
  end

  before(:each) do
    @test_asset = create(:buslike_asset, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  let(:test_calculator) { ReplacementCostCalculator.new }

  it 'get replacement cost' do
    expect(test_calculator.calculate(@test_asset)).to eq(@test_asset.policy_analyzer.get_replacement_cost)
  end
end
