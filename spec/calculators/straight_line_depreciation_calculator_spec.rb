require 'rails_helper'

RSpec.describe StraightLineDepreciationCalculator, :type => :calculator do

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

  let(:test_calculator) { StraightLineDepreciationCalculator.new }

  describe '#calculate' do
    it 'calculates' do
      # set percent residual value so easy to predict
      @policy_item.pcnt_residual_value = 25
      @policy_item.save

      expect(test_calculator.calculate(@test_asset)).to eq(500)
    end

    it 'returns purchase cost if asset is new' do
      @test_asset.manufacture_year = Date.today.year
      @test_asset.save

      expect(test_calculator.calculate(@test_asset)).to eq(@test_asset.purchase_cost)
    end

    it 'returns residual value if larger than calculated' do
      # make test_asset impossibly old
      @test_asset.manufacture_year = 1900
      @test_asset.save

      # set percent residual value so easy to predict
      @policy_item.pcnt_residual_value = 50
      @policy_item.save

      expect(test_calculator.calculate(@test_asset)).to eq(test_calculator.residual_value(@test_asset))
    end
  end

end
