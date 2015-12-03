require 'rails_helper'

RSpec.describe AssetScheduleRehabilitationUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it '.run' do
    test_asset = create(:equipment_asset)
    test_event = test_asset.schedule_rehabilitation_updates.create!(attributes_for(:schedule_rehabilitation_update_event))
    AssetScheduleRehabilitationUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.scheduled_rehabilitation_year).to eq(test_event.rebuild_year)

  end
end
