require 'rails_helper'

RSpec.describe AssetRehabilitationUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it '.run' do
    test_asset = create(:equipment_asset)
    test_event = test_asset.rehabilitation_updates.create!(attributes_for(:rehabilitation_update_event))
    AssetRehabilitationUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.last_rehabilitation_date).to eq(Date.today)
    expect(test_asset.scheduled_rehabilitation_year).to be nil
  end
end
