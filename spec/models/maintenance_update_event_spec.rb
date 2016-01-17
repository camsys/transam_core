require 'rails_helper'

RSpec.describe MaintenanceUpdateEvent, :type => :model do

  let(:test_event) { create(:equipment_asset, :parent => create(:equipment_asset)).maintenance_updates.create!(attributes_for(:maintenance_update_event, :maintenance_type_id => create(:maintenance_type).id)) }

  describe 'associations' do
    it 'has a type' do
      expect(test_event).to belong_to(:maintenance_type)
    end
  end

  describe 'validations' do
    it 'must have a  type' do
      test_event.maintenance_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(MaintenanceUpdateEvent.allowable_params).to eq([
      :maintenance_type_id
    ])
  end
  it '#asset_event_type' do
    expect(MaintenanceUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'MaintenanceUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq(test_event.maintenance_type)
  end

  it '.set_defaults' do
    expect(MaintenanceUpdateEvent.new.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'MaintenanceUpdateEvent'))
  end
end
