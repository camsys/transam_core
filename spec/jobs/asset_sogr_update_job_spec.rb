require 'rails_helper'

RSpec.describe AssetSogrUpdateJob, :type => :job do

  before(:all) do
    @parent_organization = create(:organization_basic)
    @organization = create(:organization_basic)
    @asset_type = create(:equipment_type)
    @asset_subtype = create(:asset_subtype, :asset_type => @asset_type)
    @parent_policy = create(:policy, :organization => @parent_organization, :parent => nil)
    @policy = create(:policy, :organization => @organization, :parent => @parent_policy)

    @policy_asset_type_rule = create(:policy_asset_type_rule, :asset_type => @asset_type, :policy => @parent_policy)
    @policy_asset_subtype_rule = create(:policy_asset_subtype_rule, :asset_subtype => @asset_subtype, :policy => @parent_policy)

    @policy.policy_asset_type_rules << @policy_asset_type_rule
    @policy.policy_asset_subtype_rules << @policy_asset_subtype_rule

    @test_asset = create(:equipment_asset_basic_org, :organization => @organization, :asset_type => @asset_type, :asset_subtype => @asset_subtype)
  end

  it '.run' do
    expect(@test_asset.policy_replacement_year).to be nil

    AssetSogrUpdateJob.new(@test_asset.object_key).run
    @test_asset.reload

    expect(@test_asset.policy_replacement_year).not_to be nil
  end

  it '.prepare' do
    @test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))
    expect(Rails.logger).to receive(:debug).with("Executing AssetSogrUpdateJob at #{Time.now.to_s} for Asset #{@test_asset.object_key}")
    AssetSogrUpdateJob.new(@test_asset.object_key).prepare
  end
end
