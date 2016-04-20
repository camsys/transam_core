require 'rails_helper'

RSpec.describe AssetSogrUpdateJob, :type => :job do
  
  let(:test_asset) { create(:equipment_asset_basic_org) }

  it '.run' do
    expect(test_asset.policy_replacement_year).to be nil
    test_policy = create(:policy, :organization => test_asset.organization)
    create(:policy_asset_type_rule, :policy => test_policy, :asset_type => test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => test_policy, :asset_subtype => test_asset.asset_subtype)
    test_event = test_asset.condition_updates.create!(attributes_for(:condition_update_event))
    AssetSogrUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.policy_replacement_year).not_to be nil
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))
    expect(Rails.logger).to receive(:debug).with("Executing AssetSogrUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetSogrUpdateJob.new(test_asset.object_key).prepare
  end
end
