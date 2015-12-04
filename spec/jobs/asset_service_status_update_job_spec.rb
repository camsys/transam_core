require 'rails_helper'

RSpec.describe AssetServiceStatusUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset) }

  it '.run' do
    test_event = test_asset.service_status_updates.create!(attributes_for(:service_status_update_event))
    AssetServiceStatusUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.service_status_date).to eq(Date.today)
    expect(test_asset.service_status_type).to eq(test_event.service_status_type)
  end

  it '.prepare' do
    expect(Rails.logger).to receive(:debug).with("Executing AssetServiceStatusUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetServiceStatusUpdateJob.new(test_asset.object_key).prepare
  end
end
