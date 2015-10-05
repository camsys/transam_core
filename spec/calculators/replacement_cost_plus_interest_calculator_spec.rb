require 'rails_helper'

RSpec.describe ReplacementCostPlusInterestCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  class Vehicle < Asset
    def cost
      purchase_cost
    end
  end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
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
