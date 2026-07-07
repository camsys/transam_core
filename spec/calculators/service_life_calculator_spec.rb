require 'rails_helper'
include FiscalYear

RSpec.describe ServiceLifeCalculator, :type => :calculator do

  before(:each) do
    in_service_date = Date.new(2001,1,1)
    @organization = create(:organization)
    @test_asset = create(:transam_asset, :organization => @organization, :in_service_date => in_service_date, :purchase_date => in_service_date)
    @policy = create(:policy, :organization => @organization)
    @condition_update_event = ConditionUpdateEvent.create(:transam_asset => @test_asset, assessed_rating: 2.0)
    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    @test_rule = create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)
  end

  after(:each) do
    ConditionUpdateEvent.destroy_all
  end

  let(:test_calculator) { ServiceLifeCalculator.new }

  describe '#by_age' do
    it 'calculates the life of an asset' do
       expect(test_calculator.send(:by_age,@test_asset)).to eq(2009)
    end
  end

  describe '#by_condition' do

    it 'calculates' do
      expect(test_calculator.send(:by_condition,@test_asset)).to eq(fiscal_year_year_on_date(Date.today))
    end

    it 'is by age if assessed_rating is greater than condition threshold' do
      @condition_update_event.assessed_rating = 3.0
      @test_asset.update!(in_service_date: Date.today - 1.year)
      @condition_update_event.save
      expect(test_calculator.send(:by_condition,@test_asset)).to eq(test_calculator.send(:by_age,@test_asset))
    end

    it 'is next planning year if asset is in backlog' do
      @condition_update_event.assessed_rating = 3.0
      @condition_update_event.save
      expect(test_calculator.send(:by_condition,@test_asset)).to eq(current_planning_year_year + 1)
    end

  end

end
