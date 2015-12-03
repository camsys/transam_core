require 'rails_helper'

RSpec.describe AssetServiceStatusUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it '.run' do
    test_asset = create(:equipment_asset)
    test_event = test_asset.service_status_updates.create!(attributes_for(:service_status_update_event))
    AssetServiceStatusUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.service_status_date).to eq(Date.today)
    expect(test_asset.service_status_type).to eq(test_event.service_status_type)
  end
end
