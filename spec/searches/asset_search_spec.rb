require 'spec_helper'

RSpec.describe AssetSearcher do
  let(:bus) { create(:bus) }
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer' do
    searcher = AssetSearcher.new(:manufacturer_ids => [bus.manufacturer.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:manufacturer_ids)).to be true
    expect(searcher.data).to eq(Asset.where('manufacturer_id = ?', [bus.manufacturer_id]))
  end

  it 'should be able to search by fta_funding_type' do
    searcher = AssetSearcher.new(:fta_funding_type_ids => [bus.fta_funding_type.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_funding_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_funding_type_id = ?', [bus.fta_funding_type.id]))
  end

  it 'should be able to search by fta_ownership_type' do
    searcher = AssetSearcher.new(:fta_ownership_type_ids => [bus.fta_ownership_type.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_ownership_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_ownership_type_id = ?', [bus.fta_ownership_type.id]))
  end

  it 'should be able to search by fta_vehicle_type' do
    searcher = AssetSearcher.new(:fta_vehicle_type_ids => [bus.fta_vehicle_type.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_vehicle_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_vehicle_type_id = ?', [bus.fta_vehicle_type.id]))
  end

  it 'should be able to search by asset_type' do
    searcher = AssetSearcher.new(:asset_type_ids => [bus.asset_type.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:asset_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_type_id = ?', [bus.asset_type.id]))
  end

  it 'should be able to search by asset_subtype' do
    searcher = AssetSearcher.new(:asset_subtype_ids => [bus.asset_subtype.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:asset_subtype_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_subtype_id = ?', [bus.asset_subtype.id]))
  end

  it 'should be able to search by vendor' do
    searcher = AssetSearcher.new(:vendor_ids => [bus.vendor], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:vendor_ids)).to be true
    expect(searcher.data).to eq(Asset.where('vendor_id = ?', [bus.vendor.id]))
  end

  it 'should be able to search by vendor' do
    searcher = AssetSearcher.new(:vendor_ids => [bus.vendor], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:vendor_ids)).to be true
    expect(searcher.data).to eq(Asset.where('vendor_id = ?', [bus.vendor.id]))
  end

  it 'should be able to search by service_status_type' do
    searcher = AssetSearcher.new(:service_status_type_ids => [bus.service_status_type.id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:service_status_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('service_status_type_id = ?', [bus.vendor.id]))
  end
end
