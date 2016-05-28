require 'rails_helper'
include FiscalYear

RSpec.describe ServiceLifeAgeOnly, :type => :calculator do

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
    @condition_update_event = ConditionUpdateEvent.create(:asset => @test_asset)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  let(:test_calculator) { ServiceLifeAgeOnly.new }

  it 'calculates' do
    expect(test_calculator.calculate(@test_asset)).to eq(2011)
  end

end
