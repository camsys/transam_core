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

# A separate top-level describe, deliberately outside the block above: that
# block's `before { skip(...) }` would otherwise skip this too.
# No legacy counterpart - reclassified 2026-09-02, previously mislabeled
# "Mirrors spec/jobs/asset_location_update_job_spec.rb:10-17".
# That legacy job spec exists but has never run: its whole describe opens
# `before { skip('LocationUpdateEvent assumes transam_asset. Not yet
# testable.') }`, and that skip predates TTPLAT-3072. A skipped example
# protects no behavior, so this is new ground, not restored parity.
#
# On the assertion: the legacy job would have asserted on parent_id and
# location_comments, fields specific to the old Asset model. The surviving
# LocationUpdateEvent#update_asset sets location_id directly, so the
# assertion is authored against that instead.
RSpec.describe LocationUpdateEvent, :type => :model do
  describe '#update_asset' do
    it "sets the transam_asset's location_id to the event's parent" do
      new_location = create(:buslike_asset)
      test_asset = create(:buslike_asset)
      expect(test_asset.location_id).to be_nil

      test_asset.location_updates.create!(:parent => new_location)
      test_asset.reload

      expect(test_asset.location_id).to eq(new_location.id)
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen
  describe '#api_json' do
    it 'includes parent_key and parent_name' do
      new_location = create(:buslike_asset)
      test_asset = create(:buslike_asset)
      event = test_asset.location_updates.create!(:parent => new_location)

      result = event.api_json

      expect(result[:parent_key]).to eq(new_location.object_key)
      expect(result[:parent_name]).to eq(new_location.asset_tag)
    end
  end
end
