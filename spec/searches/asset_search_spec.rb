require 'spec_helper'

RSpec.describe AssetSearcher do
  let(:bus) { create(:bus) }
  #------------------------------------------------------------------------------
  #
  # Simple Equality Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer' do
    searcher = AssetSearcher.new(:manufacturer_ids => [bus.manufacturer_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:manufacturer_ids)).to be true
    expect(searcher.data).to eq(Asset.where('manufacturer_id = ?', [bus.manufacturer_id]))
  end

  it 'should be able to search by fta funding type' do
    searcher = AssetSearcher.new(:fta_funding_type_ids => [bus.fta_funding_type_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_funding_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_funding_type_id = ?', [bus.fta_funding_type_id]))
  end

  it 'should be able to search by fta ownership type' do
    searcher = AssetSearcher.new(:fta_ownership_type_ids => [bus.fta_ownership_type_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_ownership_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_ownership_type_id = ?', [bus.fta_ownership_type_id]))
  end

  it 'should be able to search by fta vehicle_type' do
    searcher = AssetSearcher.new(:fta_vehicle_type_ids => [bus.fta_vehicle_type_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_vehicle_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('fta_vehicle_type_id = ?', [bus.fta_vehicle_type_id]))
  end

  it 'should be able to search by asset type' do
    searcher = AssetSearcher.new(:asset_type_ids => [bus.asset_type_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:asset_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_type_id = ?', [bus.asset_type_id]))
  end

  it 'should be able to search by asset subtype' do
    searcher = AssetSearcher.new(:asset_subtype_ids => [bus.asset_subtype_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:asset_subtype_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_subtype_id = ?', [bus.asset_subtype_id]))
  end

  it 'should be able to search by condition type' do
    searcher = AssetSearcher.new(:condition_type_ids => [bus.asset_subtype_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:condition_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('condition_type_id = ?', [bus.asset_subtype_id]))
  end

  it 'should be able to search by service status' do
    searcher = AssetSearcher.new(:service_status_type_ids => [bus.service_status_type_id], :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:service_status_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('service_status_type_id = ?', [bus.service_status_type_id]))
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

  it 'should be able to search by manufacture year' do
    searcher = AssetSearcher.new(:manufacture_year => bus.manufacture_year, :manufacture_year_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:manufacture_year)).to be true
    expect(searcher.data).to eq(Asset.where('manufacture_year = ?', bus.manufacture_year))

    searcher = AssetSearcher.new(:manufacture_year => bus.manufacture_year, :manufacture_year_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('manufacture_year < ?', bus.manufacture_year))

    searcher = AssetSearcher.new(:manufacture_year => bus.manufacture_year, :manufacture_year_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('manufacture_year > ?', bus.manufacture_year))
  end

  it 'should be able to search by in service date' do
    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date_comparator => '0', :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:in_service_date)).to be true
    expect(searcher.data).to eq(Asset.where('in_service_date = ?', bus.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date_comparator => '-1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('in_service_date < ?', bus.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => bus.in_service_date, :in_service_date_comparator => '1', :organization_id => bus.organization.id )
    expect(searcher.data).to eq(Asset.where('in_service_date > ?', bus.in_service_date))
  end

  #------------------------------------------------------------------------------
  #
  # Checkbox Searches
  #
  #------------------------------------------------------------------------------

  it 'should be able to search by in backlog status' do
    searcher = AssetSearcher.new(:in_backlog => bus.in_backlog, :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:in_backlog)).to be true

    expect(searcher.data).to eq(Asset.where('in_backlog = ?', bus.in_backlog))
  end

  it 'should be able to search by in purchased new' do
    searcher = AssetSearcher.new(:purchased_new => bus.purchased_new, :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:purchased_new)).to be true

    expect(searcher.data).to eq(Asset.where('purchased_new = ?', bus.purchased_new))
  end

  it 'should be able to search by ada accessible lift' do
    searcher = AssetSearcher.new(:ada_accessible_lift => bus.ada_accessible_lift, :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:ada_accessible_lift)).to be true

    expect(searcher.data).to eq(Asset.where('ada_accessible_lift = ?', bus.ada_accessible_lift))
  end

  it 'should be able to search by ada accessible ramp' do
    searcher = AssetSearcher.new(:ada_accessible_ramp => bus.ada_accessible_ramp, :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:ada_accessible_ramp)).to be true

    expect(searcher.data).to eq(Asset.where('ada_accessible_ramp = ?', bus.ada_accessible_ramp))
  end

  it 'should be able to search by fta_emergency_contingency_fleet' do
    searcher = AssetSearcher.new(:fta_emergency_contingency_fleet => bus.fta_emergency_contingency_fleet, :organization_id => bus.organization.id )
    expect(searcher.respond_to?(:fta_emergency_contingency_fleet)).to be true

    expect(searcher.data).to eq(Asset.where('fta_emergency_contingency_fleet = ?', bus.fta_emergency_contingency_fleet))
  end

end
