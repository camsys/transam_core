require 'rails_helper'

RSpec.describe AssetLocationUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset, :parent => create(:equipment_asset)) }

  it '.run' do
    test_event = test_asset.location_updates.create!(attributes_for(:location_update_event))
    AssetLocationUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.parent_id).to eq(test_event.parent_id)
    expect(test_asset.location_comments).to eq(test_event.comments)
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetLocationUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetLocationUpdateJob.new(test_asset.object_key).prepare
  end
end
