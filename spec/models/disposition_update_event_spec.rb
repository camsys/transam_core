require 'rails_helper'

RSpec.describe DispositionUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset).disposition_updates.create!(attributes_for(:disposition_update_event)) }

  describe 'associations' do
    it 'has a type' do
      expect(test_event).to belong_to(:disposition_type)
    end
  end
  describe 'validations' do
    it 'must have a type' do
      test_event.disposition_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(DispositionUpdateEvent.allowable_params).to eq([:disposition_type_id])
  end
  it '#asset_event_type' do
    expect(DispositionUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'DispositionUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("#{test_event.disposition_type.to_s} on #{Date.today}")
  end

  it '.set_defaults' do
    expect(create(:buslike_asset).disposition_updates.new.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'DispositionUpdateEvent'))
  end
end
