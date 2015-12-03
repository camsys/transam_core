require 'rails_helper'

RSpec.describe AssetScheduleReplacementUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it '.run' do
    test_asset = create(:equipment_asset)
    test_event = test_asset.schedule_replacement_updates.create!(attributes_for(:schedule_replacement_update_event))
    test_policy = create(:policy, :organization => test_asset.organization)
    create(:policy_asset_type_rule, :policy => test_policy, :asset_type => test_asset.asset_type)
    create(:policy_asset_subtype_rule, :policy => test_policy, :asset_subtype => test_asset.asset_subtype)

    AssetScheduleReplacementUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.scheduled_replacement_year).to eq(test_event.replacement_year)
    expect(test_asset.replacement_reason_type).to eq(test_event.replacement_reason_type)
  end
end
