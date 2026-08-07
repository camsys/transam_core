require 'rails_helper'
include FiscalYear

RSpec.describe ServiceLifeAgeOnly, :type => :calculator do

  before(:each) do
    in_service_date = Date.new(2001,1,1)
    @organization = create(:organization)
    @test_asset = create(:transam_asset, :organization => @organization, :in_service_date => in_service_date, :purchase_date => in_service_date)
    @policy = create(:policy, :organization => @organization)
    @condition_update_event = ConditionUpdateEvent.create(:transam_asset => @test_asset)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  after(:each) do
    ConditionUpdateEvent.destroy_all
  end

  let(:test_calculator) { ServiceLifeAgeOnly.new }

  it 'calculates' do
    expect(test_calculator.calculate(@test_asset)).to eq(2009)
  end

end
