require 'rails_helper'

RSpec.describe AssetScheduleReplacementUpdateJob, :type => :job do

  before(:all) do
    @parent_organization = create(:organization_basic)
    @organization = create(:organization_basic)
    @asset_subtype = create(:asset_subtype)
    @parent_policy = create(:policy, :organization => @parent_organization, :parent => nil)
    @policy_asset_subtype_rule = create(:policy_asset_subtype_rule, :asset_subtype => @asset_subtype, :policy => @parent_policy)
    @policy = create(:policy, :organization => @organization, :parent => @parent_policy)
    @policy.policy_asset_subtype_rules << @policy_asset_subtype_rule
    @test_asset = create(:equipment_asset_basic_org, :organization => @organization, :asset_type => @asset_subtype.asset_type, :asset_subtype => @asset_subtype)
  end

  it 'sogr update' do
    expect(AssetScheduleReplacementUpdateJob.new(0).requires_sogr_update?).to be true
  end

  it '.run' do
    test_event = @test_asset.schedule_replacement_updates.create!(attributes_for(:schedule_replacement_update_event))

    create(:policy_asset_type_rule, :policy => @policy, :asset_type => @test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => @policy, :asset_subtype => @test_asset.asset_subtype)

    AssetScheduleReplacementUpdateJob.new(@test_asset.object_key).run
    @test_asset.reload

    expect(@test_asset.scheduled_replacement_year).to eq(test_event.replacement_year)
    expect(@test_asset.replacement_reason_type).to eq(test_event.replacement_reason_type)
  end

  it '.prepare' do
    @test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetScheduleReplacementUpdateJob at #{Time.now.to_s} for Asset #{@test_asset.object_key}")
    AssetScheduleReplacementUpdateJob.new(@test_asset.object_key).prepare
  end
end
