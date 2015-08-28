require 'rails_helper'
include FiscalYear

RSpec.describe ServiceLifeCalculator, :type => :calculator do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  class Vehicle < Asset; end

  before(:each) do
    @organization = create(:organization)
    @test_asset = create(:buslike_asset, :organization => @organization)
    @policy = create(:policy, :organization => @organization)
    @policy_item = create(:policy_item, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
    @condition_update_event = ConditionUpdateEvent.create(:asset => @test_asset)
  end

  let(:test_calculator) { ServiceLifeCalculator.new }

  describe '#by_age' do
    it 'calculates' do
      expect(test_calculator.send(:by_age,@test_asset)).to eq(2010)
    end

    it 'is equal to in service year if policy max life is 0 and asset expected life was not assigned' do

      @policy_item.max_service_life_months = 0
      @policy_item.save

      expect(test_calculator.send(:by_age,@test_asset)).to eq(2000)

    end
  end

  describe '#by_condition' do

    it 'calculates' do
      expect(test_calculator.send(:by_condition,@test_asset)).to eq(fiscal_year_year_on_date(Date.today))
    end

    it 'is by age if assessed_rating is greater than condition threshold' do
      @condition_update_event.assessed_rating = 3.0
      @condition_update_event.save
      expect(test_calculator.send(:by_condition,@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end

  end

end
