require 'rails_helper'

RSpec.describe DecliningBalanceDepreciationCalculator, :type => :calculator do

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

  let(:test_calculator) { DecliningBalanceDepreciationCalculator.new }

  describe '#calculate' do
    it 'calculates correctly' do
      puts test_calculator.calculate(@test_asset)
      ### TESTS TO BE WRITTEN ###
    end
  end

end
