require 'rails_helper'

RSpec.describe ConditionUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset, :purchase_date => Date.today).condition_updates.create!(attributes_for(:condition_update_event)) }

  describe 'associations' do
    it 'has a type' do
      expect(test_event).to belong_to(:condition_type)
    end
  end

  describe 'validations' do
    it 'must have a condition type' do
      test_event.assessed_rating = 25
      test_event.condition_type = nil
      expect(test_event.valid?).to be false
    end
    describe 'assessed rating must be in range' do
      it 'cant be above max' do
        test_event.assessed_rating = ConditionType.maximum(:rating)+1.0
        expect(test_event.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(ConditionUpdateEvent.allowable_params).to eq([:condition_type_id, :assessed_rating])
  end
  it '#asset_event_type' do
    expect(ConditionUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'ConditionUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("#{sprintf("%#.1f", test_event.assessed_rating)} (#{test_event.condition_type.to_s})")
  end

  describe '.set_defaults' do
    it 'asset reported condition rating' do
      expect(create(:buslike_asset, :reported_condition_rating => 2.0).condition_updates.new.assessed_rating).to eq(2.0)
    end
    it 'default to max condition type' do
      expect(create(:buslike_asset, :reported_condition_rating => nil).condition_updates.new.assessed_rating).to eq(5.0)
    end
    it 'asset event type' do
      expect(create(:buslike_asset).condition_updates.new.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'ConditionUpdateEvent'))
    end
  end
end
