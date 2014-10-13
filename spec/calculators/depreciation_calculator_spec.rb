require 'rails_helper'

RSpec.describe DepreciationCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.find_by_organization_id(self.id)
    end
  end

  class Vehicle < Asset; end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
    @policy_item = create(:policy_item, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end


  let(:test_calculator) { DepreciationCalculator.new }

  describe '#basis' do
    it 'is 0 for a purchase price of 0' do
      @test_asset.purchase_cost = 0
      expect(test_calculator.basis(@test_asset)).to eq(0)
    end

    it 'is 0 for a percentage residual value of 100' do
      #
    end

  end

  describe '#residual_value' do
    #
  end

end
