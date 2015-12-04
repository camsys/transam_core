require 'rails_helper'

RSpec.describe AssetDispositionUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset) }

  it '.run' do
    test_event = test_asset.disposition_updates.create!(attributes_for(:disposition_update_event))
    AssetDispositionUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.disposition_date).to eq(Date.today)
    expect(test_asset.disposition_type).to eq(test_event.disposition_type)
    expect(test_asset.service_status_type).to eq(ServiceStatusType.find_by(:code => 'D'))
  end

  it '.prepare' do
    expect(Rails.logger).to receive(:debug).with("Executing AssetDispositionUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetDispositionUpdateJob.new(test_asset.object_key).prepare
  end
end
