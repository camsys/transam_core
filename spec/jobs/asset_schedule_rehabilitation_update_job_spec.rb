require 'rails_helper'

RSpec.describe AssetScheduleRehabilitationUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset) }

  it '.run' do
    test_event = test_asset.schedule_rehabilitation_updates.create!(attributes_for(:schedule_rehabilitation_update_event))
    AssetScheduleRehabilitationUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.scheduled_rehabilitation_year).to eq(test_event.rebuild_year)
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetScheduleRehabilitationUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetScheduleRehabilitationUpdateJob.new(test_asset.object_key).prepare
  end
end
