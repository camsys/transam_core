require 'rails_helper'

RSpec.describe LocationUpdateEvent, :type => :model do
  before { skip('LocationUpdateEvent assumes transam_asset. Not yet testable.') }

  let(:parent_asset) { create(:equipment_asset) }
  let(:main_asset) { create(:equipment_asset, :parent => parent_asset) }
  let(:test_event) { main_asset.location_updates << create(:location_update_event) }

  describe 'associations' do
    it 'has a parent' do
      expect(test_event).to belong_to(:parent)
    end
  end
  describe 'validations' do
    it 'must have a parent' do
      test_event.parent = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(LocationUpdateEvent.allowable_params).to eq([
      :parent_key,
      :parent_name
    ])
  end
  it '#asset_event_type' do
    expect(LocationUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'LocationUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update.to_s).to eq("Located at #{test_event.parent.asset_subtype} #{test_event.parent}")
  end
  it '.parent_key' do
    expect(test_event.parent_key).to eq(test_event.parent.object_key)
  end
  it '.parent_name' do
    expect(test_event.parent_name).to eq(test_event.parent.name)
  end

  describe '.set_defaults' do
    it 'type' do
      expect(test_event.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'LocationUpdateEvent'))
    end
    it 'parent' do
      expect(test_event.parent).to eq(test_event.asset.parent)
    end
  end
end
