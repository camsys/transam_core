require 'rails_helper'

RSpec.describe AssetMaintenanceUpdateJob, :type => :job do

  let(:test_asset) { create(:equipment_asset) }

  it 'sogr update' do
    expect(AssetMaintenanceUpdateJob.new(0).requires_sogr_update?).to be false
  end

  it '.run' do
    test_event = test_asset.maintenance_updates.create!(attributes_for(:maintenance_update_event, :maintenance_type_id => create(:maintenance_type).id))
    AssetMaintenanceUpdateJob.new(test_asset.object_key).run
    test_asset.reload

    expect(test_asset.last_maintenance_date).to eq(Date.today)
  end

  it '.prepare' do
    test_asset.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))
    expect(Rails.logger).to receive(:debug).with("Executing AssetMaintenanceUpdateJob at #{Time.now.to_s} for Asset #{test_asset.object_key}")
    AssetMaintenanceUpdateJob.new(test_asset.object_key).prepare
  end
end
