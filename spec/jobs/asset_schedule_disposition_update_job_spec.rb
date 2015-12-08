require 'rails_helper'

RSpec.describe AssetScheduleDispositionUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset) }

  it '.run' do
    test_event = test_asset.schedule_disposition_updates.create!(attributes_for(:schedule_disposition_update_event))
    AssetScheduleDispositionUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.scheduled_disposition_year).to eq(test_event.disposition_year)

  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetScheduleDispositionUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetScheduleDispositionUpdateJob.new(test_asset.object_key).prepare
  end
end
