require 'rails_helper'

RSpec.describe AssetRehabilitationUpdateJob, :type => :job do

  class TestOrg < Organization
    def get_policy
      return Policy.where("`organization_id` = ?",self.id).order('created_at').last
    end
  end

  let(:test_asset) { create(:equipment_asset) }

  it '.run' do
    test_event = test_asset.rehabilitation_updates.create!(attributes_for(:rehabilitation_update_event))
    AssetRehabilitationUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.last_rehabilitation_date).to eq(Date.today)
    expect(test_asset.scheduled_rehabilitation_year).to be nil
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing AssetRehabilitationUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetRehabilitationUpdateJob.new(test_asset.object_key).prepare
  end
end
