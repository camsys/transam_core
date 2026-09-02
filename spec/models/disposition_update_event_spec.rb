require 'rails_helper'

RSpec.describe DispositionUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset).disposition_updates.create!(attributes_for(:disposition_update_event)) }

  describe 'associations' do
    it 'has a type' do
      skip 'DispositionUpdateEvent assumes transam_asset. Not yet testable.'
      expect(test_event).to belong_to(:disposition_type)
    end
  end
  describe 'validations' do
    it 'must have a type' do
      skip 'DispositionUpdateEvent assumes transam_asset. Not yet testable.'
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
    skip 'DispositionUpdateEvent assumes transam_asset. Not yet testable.'
    expect(test_event.get_update).to eq("#{test_event.disposition_type.to_s} on #{Date.today}")
  end

  it '.set_defaults' do
    skip 'DispositionUpdateEvent assumes transam_asset. Not yet testable.'
    expect(create(:buslike_asset).disposition_updates.new.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'DispositionUpdateEvent'))
  end

  # Mirrors spec/jobs/asset_disposition_update_job_spec.rb:8-18 (skipped '.run') -
  # disposition_type_id 5 ("Disposed") is used deliberately to isolate the
  # disposition_date mutation; disposition_type_id 2 ("Transferred") would also
  # exercise TransamAssetRecord#transfer, which is a separate, currently-untested
  # method (M3) and out of scope here.
  describe '#update_asset' do
    it 'sets the disposition_date on the transam_asset to the event date' do
      test_asset = create(:buslike_asset)
      expect(test_asset.disposition_date).to be_nil

      event = test_asset.disposition_updates.create!(attributes_for(:disposition_update_event, :disposition_type_id => 5, :event_date => Date.today))
      test_asset.reload

      expect(test_asset.disposition_date).to eq(event.event_date)
    end
  end

  # DispositionUpdateEvent#api_json (M16) is not written here: mileage_at_disposition
  # is supplied by transam_transit (alias_attribute onto current_mileage, reopening
  # this class), not a core bug. See ttplat-3072-mirror-brief.md §3a. Moved to the
  # transit brief.
end
