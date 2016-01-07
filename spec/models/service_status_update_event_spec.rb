require 'rails_helper'

RSpec.describe ServiceStatusUpdateEvent, :type => :model do
  let(:test_event) { create(:buslike_asset).service_status_updates.create!(attributes_for(:service_status_update_event)) }

  describe 'associations' do
    it 'must have a status type' do
      expect(test_event).to belong_to(:service_status_type)
    end
  end
  describe 'validations' do
    it 'must have a status type' do
      test_event.service_status_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(ServiceStatusUpdateEvent.allowable_params).to eq([:service_status_type_id])
  end
  it '#asset_event_type' do
    expect(ServiceStatusUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'ServiceStatusUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("Service status changed to #{test_event.service_status_type.to_s}.")
  end

  it '.set_defaults' do
    expect(create(:buslike_asset).service_status_updates.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'ServiceStatusUpdateEvent'))
  end
end
