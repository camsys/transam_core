require 'rails_helper'

RSpec.describe AssetConditionUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  it 'sogr update' do
    expect(AssetConditionUpdateJob.new(0).requires_sogr_update?).to be true
  end

  it '.run' do
    test_asset = create(:equipment_asset)
    test_event = test_asset.condition_updates.create!(attributes_for(:condition_update_event))
    AssetConditionUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.reported_condition_date).to eq(Date.today)
    expect(test_asset.reported_condition_rating).to eq(test_event.assessed_rating)
    expect(test_asset.reported_condition_type).to eq(ConditionType.from_rating(test_event.assessed_rating))
  end
end
