require 'spec_helper'

RSpec.describe AssetSearcher do
  let(:bus) { create(:bus) }
  #------------------------------------------------------------------------------
  #
  # Simple Equality Searches
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
    expect(searcher.data).to eq(Asset.where('service_status_type_id = ?', [bus.service_status_type.id]))
  end

  #------------------------------------------------------------------------------
  #
  # Comparator Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by purchase cost' do
    searcher = AssetSearcher.new(:purchase_cost => [bus.purchase_cost], :purchase_cost_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:purchase_cost)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_cost = ?', [bus.purchase_cost]))

    searcher = AssetSearcher.new(:purchase_cost => [bus.purchase_cost], :purchase_cost_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('purchase_cost < ?', [bus.purchase_cost]))

    searcher = AssetSearcher.new(:purchase_cost => [bus.purchase_cost], :purchase_cost_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('purchase_cost > ?', [bus.purchase_cost]))
  end

  it 'should be able to search by book value' do
    searcher = AssetSearcher.new(:book_value => bus.book_value, :book_value_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:book_value)).to be true
    expect(searcher.data).to eq(Asset.where('book_value = ?', bus.book_value))

    searcher = AssetSearcher.new(:book_value => bus.book_value, :book_value_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('purchase_cost < ?', bus.book_value))

    searcher = AssetSearcher.new(:book_value => bus.book_value, :book_value_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('book_value > ?', bus.book_value))
  end

  it 'should be able to search by replacement year' do
    searcher = AssetSearcher.new(:replacement_year => bus.replacement_year, :replacement_year_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('replacement_year = ?', bus.replacement_year))

    searcher = AssetSearcher.new(:replacement_year => bus.replacement_year, :replacement_year_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('replacement_year < ?', bus.replacement_year))

    searcher = AssetSearcher.new(:replacement_year => bus.replacement_year, :replacement_year_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('replacement_year > ?', [bus.replacement_year]))
  end

  it 'should be able to search by scheduled replacement year' do
    searcher = AssetSearcher.new(:scheduled_replacement_year => bus.scheduled_replacement_year, :scheduled_replacement_year_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:scheduled_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year = ?', bus.scheduled_replacement_year))

    searcher = AssetSearcher.new(:scheduled_replacement_year => scheduled_replacement_year, :scheduled_replacement_year_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year < ?', bus.scheduled_replacement_year))

    searcher = AssetSearcher.new(:scheduled_replacement_year => bus.scheduled_replacement_year, :scheduled_replacement_year_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year > ?', bus.scheduled_replacement_year))
  end

  it 'should be able to search by policy replacement year' do
    searcher = AssetSearcher.new(:policy_replacement_year => bus.policy_replacement_year, :policy_replacement_year_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:policy_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('policy_replacement_year = ?', bus.policy_replacement_year))

    searcher = AssetSearcher.new(:policy_replacement_year => bus.policy_replacement_year, :policy_replacement_year_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year < ?', bus.policy_replacement_year))

    searcher = AssetSearcher.new(:policy_replacement_year => bus.policy_replacement_year, :scheduled_replacement_year_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year > ?', bus.policy_replacement_year))
  end

  it 'should be able to search by purchase date' do
    searcher = AssetSearcher.new(:purchase_date => bus.purchase_date, :purchase_date_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:purchase_date)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_date = ?', bus.purchase_date))

    searcher = AssetSearcher.new(:purchase_date => bus.purchase_date, :purchase_date_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('purchase_date < ?', bus.purchase_date))

    searcher = AssetSearcher.new(:purchase_date => bus.purchase_date, :purchase_date_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('purchase_date > ?', bus.purchase_date))
  end

  it 'should be able to search by reported mileage' do
    searcher = AssetSearcher.new(:reported_mileage => bus.reported_mileage, :reported_mileage_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:reported_mileage)).to be true
    expect(searcher.data).to eq(Asset.where('reported_mileage = ?', bus.reported_mileage))

    searcher = AssetSearcher.new(:reported_mileage => bus.reported_mileage, :reported_mileage_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('reported_mileage < ?', bus.reported_mileage))

    searcher = AssetSearcher.new(:reported_mileage => bus.reported_mileage, :reported_mileage_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('reported_mileage > ?', bus.reported_mileage))
  end

  it 'should be able to search by manufacture date' do
    searcher = AssetSearcher.new(:manufacture_date => bus.manufacture_date, :manufacture_date_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:manufacture_date)).to be true
    expect(searcher.data).to eq(Asset.where('manufacture_date = ?', bus.manufacture_date))

    searcher = AssetSearcher.new(:manufacture_date => bus.manufacture_date, :manufacture_date_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('manufacture_date < ?', bus.manufacture_date))

    searcher = AssetSearcher.new(:manufacture_date => bus.manufacture_date, :manufacture_date_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('manufacture_date > ?', bus.manufacture_date))
  end

  it 'should be able to search by in service date' do
    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:in_service_date)).to be true
    expect(searcher.data).to eq(Asset.where('in_service_date = ?', bus.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('in_service_date < ?', bus.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('in_service_date > ?', bus.in_service_date))
  end

end
