require 'rails_helper'

RSpec.describe AssetEvent, :type => :model do

  let(:test_asset_event) { create(:asset_event) }

  # instantiate asset_event_type class for test_asset_event
  class MileageUpdateEvent < AssetEvent; end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------

  describe '.as_typed_event' do
    it "types an untyped event" do
      expect(AssetEvent.as_typed_event(test_asset_event).class).to eq(ConditionUpdateEvent)
    end

    it "types an already typed event" do
      test_asset = create(:buslike_asset)
      test_asset.condition_updates.create!(attributes_for(:condition_update_event, :asset => test_asset))
      expect(AssetEvent.as_typed_event(test_asset.condition_updates.last).class).to eq(ConditionUpdateEvent)
    end

    it "returns nil when handed nothing" do
      expect(AssetEvent.as_typed_event(nil)).to be_nil
    end
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  describe "#is_typed?" do
    it 'returns true for strongly typed assets' do
      expect(ConditionUpdateEvent.new(:asset => build_stubbed(:buslike_asset)).is_typed?).to be(true)
    end

    it 'returns false for Asset' do
      expect(test_asset_event.is_typed?).to be(false)
    end
  end

  it 'should have an asset_event_type' do
    expect(test_asset_event.asset_event_type.nil?).to be false
  end

  describe '#event_date' do
    it 'exists' do
      expect(test_asset_event.event_date.nil?).to be false
    end

    it "defaults to today's date" do
      expect(test_asset_event.event_date == Date.today).to be true
    end
  end

  describe '#asset' do
    it 'exists' do
      expect(test_asset_event.asset.nil?).to be false
    end

    it 'associations hold on asset destroy' do
      test_asset = create(:buslike_asset)
      test_asset.asset_events << test_asset_event
      test_asset.destroy

      expect(test_asset.asset_events.length).to eq(0)
    end
  end

  it 'can find previous events' do
    test_asset_event.asset.update!(:purchased_new => false)
    params = {:event_date => Date.today - 2.years, :asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    prev_event = create(:asset_event, params)

    expect(test_asset_event.previous_event_of_type == AssetEvent.as_typed_event(prev_event)).to be true

  end

  it 'can find next events' do
    params = {:event_date => Date.today + 2.years, :asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    next_event = create(:asset_event, params)

    expect(test_asset_event.next_event_of_type == AssetEvent.as_typed_event(next_event)).to be true
  end

  it 'has no previous event when its the only event' do
    expect(test_asset_event.previous_event_of_type.nil?).to be true
  end

  it 'has no next event when its the only event' do
    expect(test_asset_event.next_event_of_type.nil?).to be true
  end

  it 'can get the previous same day event of its asset' do
    params = {:asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    params["created_at"] = test_asset_event.created_at + 2.seconds
    event_created_two_seconds_later = create(:asset_event, params)

    expect(event_created_two_seconds_later.previous_event_of_type == AssetEvent.as_typed_event(test_asset_event)).to be true
  end

  it 'can get the next same day event of its asset' do
    params = {:asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    params["created_at"] = test_asset_event.created_at + 2.seconds
    event_created_two_seconds_later = create(:asset_event, params)

    expect(test_asset_event.next_event_of_type == AssetEvent.as_typed_event(event_created_two_seconds_later)).to be true
  end

  it 'has no previous event if first chronologically' do
    params = {:event_date => Date.today + 1.year,:asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    build_stubbed(:asset_event, params)

    expect(test_asset_event.previous_event_of_type.nil?).to be true
  end

  it 'has no next event if last chronologically' do
    params = {:event_date => Date.today - 1.year,:asset => test_asset_event.asset, :asset_event_type => test_asset_event.asset_event_type}
    build_stubbed(:asset_event, params)

    expect(test_asset_event.next_event_of_type.nil?).to be true
  end

  it 'returns only previous events of the same type as the caller' do
      bus = test_asset_event.asset
      bus.disposition_updates.create(attributes_for(:disposition_update_event, :event_date => Date.today - 10.years))
      previous_event = test_asset_event.previous_event_of_type

      expect(previous_event).to be_nil
    end

  it 'returns only next events of the same type as the caller' do
      bus = test_asset_event.asset
      bus.disposition_updates.create(attributes_for(:disposition_update_event, :event_date => Date.today)) # condition_update event is in the past
      next_event = test_asset_event.next_event_of_type

      expect(next_event).to be_nil
    end

end
