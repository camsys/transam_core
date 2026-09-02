require 'rails_helper'

RSpec.describe TransamAsset, :type => :model do

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen
  describe 'parent/location accessors' do
    let(:parent_asset) { create(:buslike_asset) }
    let(:location_asset) { create(:buslike_asset) }
    let(:test_asset) { create(:buslike_asset, :parent => parent_asset, :location => location_asset) }

    it 'parent_name returns the parent asset tag' do
      expect(test_asset.parent_name).to eq(parent_asset.asset_tag)
    end

    it 'parent_name returns nil when there is no parent' do
      expect(create(:buslike_asset).parent_name).to be_nil
    end

    it 'parent_key returns the parent object key' do
      expect(test_asset.parent_key).to eq(parent_asset.object_key)
    end

    it 'parent_key returns nil when there is no parent' do
      expect(create(:buslike_asset).parent_key).to be_nil
    end

    it 'parent_key= looks up and assigns the parent by object key' do
      asset = create(:buslike_asset)
      asset.parent_key = parent_asset.object_key
      expect(asset.parent).to eq(parent_asset)
    end

    it 'location_name returns the location asset tag' do
      expect(test_asset.location_name).to eq(location_asset.asset_tag)
    end

    it 'location_name returns nil when there is no location' do
      expect(create(:buslike_asset).location_name).to be_nil
    end

    it 'location_key returns the location object key' do
      expect(test_asset.location_key).to eq(location_asset.object_key)
    end

    it 'location_key returns nil when there is no location' do
      expect(create(:buslike_asset).location_key).to be_nil
    end

    it 'location_key= looks up and assigns the location by object key' do
      asset = create(:buslike_asset)
      asset.location_key = location_asset.object_key
      expect(asset.location).to eq(location_asset)
    end
  end

  # Mirrors spec/models/asset_spec.rb:72-135 (#age) - that spec covers every
  # non-nil in_service_date case; only the in_service_date.nil? branch was
  # never exercised, since it is a validated presence column and can only be
  # reached by clearing it on an already-built instance.
  describe '#age' do
    it 'returns 0 when in_service_date is nil' do
      test_asset = create(:buslike_asset)
      test_asset.in_service_date = nil
      expect(test_asset.age).to eq(0)
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen
  describe '#summary_api_json' do
    it 'returns object_key, description, and the organization api_json' do
      test_asset = create(:buslike_asset, :description => 'A test asset')

      result = test_asset.summary_api_json

      expect(result).to eq({
        object_key: test_asset.object_key,
        description: 'A test asset',
        organization: test_asset.organization.api_json
      })
    end
  end

  # No legacy counterpart - added from the TTPLAT-3072 coverage screen
  describe '#api_json' do
    it 'returns the full asset attribute hash' do
      test_asset = create(:buslike_asset, :description => 'A test asset')

      result = test_asset.api_json

      expect(result).to eq({
        object_key: test_asset.object_key,
        asset_tag: test_asset.asset_tag,
        external_id: test_asset.external_id,
        description: 'A test asset',
        organization: test_asset.organization.api_json,
        asset_subtype: test_asset.asset_subtype.api_json,
        manufacturer: nil,
        manufacturer_model: nil,
        other_manufacturer_model: test_asset.other_manufacturer_model,
        manufacture_year: test_asset.manufacture_year,
        purchase_cost: test_asset.purchase_cost,
        purchase_date: test_asset.purchase_date,
        purchased_new: test_asset.purchased_new,
        in_service_date: test_asset.in_service_date,
        vendor: nil,
        quantity: test_asset.quantity,
        quantity_unit: test_asset.quantity_unit
      })
    end

    it 'includes a typed asset_events hash, keyed by event type, when include_events is true' do
      test_asset = create(:buslike_asset)
      event = test_asset.condition_updates.create!(attributes_for(:condition_update_event))

      result = test_asset.api_json(:include_events => true)

      expect(result[:asset_events]).to be_a(Hash)
      event_type_key = event.asset_event_type.to_s
      expect(result[:asset_events][event_type_key]).to eq([AssetEvent.as_typed_event(event).api_json])
    end
  end

  # Mirrors spec/models/asset_spec.rb (legacy .very_specific coverage) - core's
  # dummy app has no model anywhere that declares acts_as :transam_assetible
  # (confirmed via repo-wide grep; transit's TransitAsset does, per the mirror
  # brief's §3a), so the recursive drill-down branch is unreachable in core
  # and out of scope here. Only the reachable, degenerate case is written:
  # with zero distinct transam_assetible_type values, the method returns
  # every TransamAsset unfiltered.
  #
  # Compares against TransamAsset.all rather than a fixed set of created
  # records: another describe block in this suite (early_disposition_request_
  # update_event_spec.rb's "sending notifications" group) creates a TransamAsset
  # in a before(:all), which is not rolled back between examples and would
  # otherwise leak into whichever count this test asserted a fixed value against.
  describe '.very_specific' do
    it 'returns every TransamAsset, unfiltered, when none has a more specific type' do
      create(:buslike_asset)
      create(:buslike_asset)

      expect(TransamAsset.very_specific.to_a).to match_array(TransamAsset.all.to_a)
    end
  end
end
