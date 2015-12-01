require 'rails_helper'

RSpec.describe LocationUpdateEvent, :type => :model do

  let(:test_event) { create(:equipment_asset, :parent => create(:equipment_asset)).location_updates.create!(attributes_for(:location_update_event)) }

  describe 'associations' do
    it 'has a parent' do
      expect(LocationUpdateEvent.column_names).to include('parent_id')
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
    expect(test_event.get_update.to_s).to eq(test_event.parent.to_s)
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
