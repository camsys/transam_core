require 'rails_helper'

RSpec.describe RehabilitationYearCalculator, :type => :calculator do

  class TestOrg < Organization
    has_many :assets,   :foreign_key => 'organization_id'

    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  class Vehicle < Asset
    def cost
      purchase_cost
    end
  end

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
