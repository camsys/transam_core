require 'rails_helper'

RSpec.describe AssetSearcher, :type => :model do
  #------------------------------------------------------------------------------
  #
  # Simple Equality Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer' do
    asset = create(:equipment_asset, :manufacturer_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:manufacturer_ids => [asset.manufacturer_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:manufacturer_ids)).to be true
    expect(searcher.data).to eq(Asset.where('manufacturer_id = ?', [asset.manufacturer_id]).to_a)
  end

  it 'should be able to search by asset type' do
    asset = create(:equipment_asset, :asset_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:asset_type_ids => [asset.asset_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:asset_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_type_id = ?', [asset.asset_type_id]).to_a)
  end

  it 'should be able to search by asset subtype' do
    asset = create(:equipment_asset, :asset_subtype_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:asset_subtype_ids => [asset.asset_subtype_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:asset_subtype_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_subtype_id = ?', [asset.asset_subtype_id]).to_a)
  end

  it 'should be able to search by estimated condition type' do
    asset = create(:equipment_asset, :estimated_condition_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:estimated_condition_type_ids => [asset.estimated_condition_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:estimated_condition_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('estimated_condition_type_id = ?', [asset.estimated_condition_type_id]).to_a)
  end

  it 'should be able to search by reported condition type' do
    asset = create(:equipment_asset, :reported_condition_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:reported_condition_type_ids => [asset.reported_condition_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:reported_condition_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('reported_condition_type_id = ?', [asset.reported_condition_type_id]).to_a)
  end

  it 'should be able to search by service status' do
    asset = create(:equipment_asset, :service_status_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:service_status_type_ids => [asset.service_status_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:service_status_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('service_status_type_id = ?', [asset.service_status_type_id]).to_a)
  end
  # #------------------------------------------------------------------------------
  # #
  # # Comparator Searches
  # #
  # #------------------------------------------------------------------------------
  it 'should be able to search by purchase cost' do
    asset = create(:equipment_asset, :purchase_cost => 10000, :organization_id => 1)
    lesser = create(:equipment_asset, :purchase_cost => 2000, :organization_id => 1)

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchase_cost)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_cost = ?', [asset.purchase_cost]).to_a)

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_cost < ?', [asset.purchase_cost]).to_a)

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_cost > ?', [asset.purchase_cost]).to_a)
  end

  it 'should be able to search by scheduled replacement year' do
    asset = create(:equipment_asset, :scheduled_replacement_year => 2020, :organization_id => 1)
    lesser = create(:equipment_asset, :scheduled_replacement_year => 2010, :organization_id => 1)

    searcher = AssetSearcher.new(:scheduled_replacement_year => asset.scheduled_replacement_year, :scheduled_replacement_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:scheduled_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year = ?', asset.scheduled_replacement_year).to_a)

    searcher = AssetSearcher.new(:scheduled_replacement_year => asset.scheduled_replacement_year, :scheduled_replacement_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year < ?', asset.scheduled_replacement_year).to_a)

    searcher = AssetSearcher.new(:scheduled_replacement_year => asset.scheduled_replacement_year, :scheduled_replacement_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year > ?', asset.scheduled_replacement_year).to_a)
  end

  it 'should be able to search by policy replacement year' do
    asset = create(:equipment_asset, :policy_replacement_year => 2020, :organization_id => 1)
    lesser = create(:equipment_asset, :policy_replacement_year => 2010, :organization_id => 1)

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :policy_replacement_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:policy_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('policy_replacement_year = ?', asset.policy_replacement_year).to_a)

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :policy_replacement_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year < ?', asset.policy_replacement_year).to_a)

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :policy_replacement_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year > ?', asset.policy_replacement_year).to_a)
  end

  it 'should be able to search by purchase date' do
    asset = create(:equipment_asset, :purchase_date => Date.today, :organization_id => 1)
    lesser = create(:equipment_asset, :purchase_date => Date.new(2000,1,1), :organization_id => 1)

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchase_date)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_date = ?', asset.purchase_date).to_a)

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_date < ?', asset.purchase_date).to_a)

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_date > ?', asset.purchase_date).to_a)
  end

  it 'should be able to search by manufacture year' do
    asset = create(:equipment_asset, :manufacture_year => 2010, :organization_id => 1)
    lesser = create(:equipment_asset, :manufacture_year => 2000, :organization_id => 1)

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:manufacture_year)).to be true
    expect(searcher.data).to eq(Asset.where('manufacture_year = ?', asset.manufacture_year).to_a)

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('manufacture_year < ?', asset.manufacture_year).to_a)

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('manufacture_year > ?', asset.manufacture_year).to_a)
  end

  it 'should be able to search by in service date' do
    asset = create(:equipment_asset, :in_service_date => Date.today, :organization_id => 1)
    lesser = create(:equipment_asset, :in_service_date => Date.new(2000,1,1), :organization_id => 1)

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:in_service_date)).to be true
    expect(searcher.data).to eq(Asset.where('in_service_date = ?', asset.in_service_date).to_a)

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('in_service_date < ?', asset.in_service_date).to_a)

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('in_service_date > ?', asset.in_service_date).to_a)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Checkbox Searches
  # #
  # #------------------------------------------------------------------------------

  it 'should be able to search by in backlog status' do
    asset = create(:equipment_asset, :in_backlog => true, :organization_id => 1)

    searcher = AssetSearcher.new(:in_backlog => "1", :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:in_backlog)).to be true

    expect(searcher.data).to eq(Asset.where(in_backlog: true).to_a)
  end

  it 'should be able to search by in purchased new' do
    asset = create(:equipment_asset, :purchased_new => true, :organization_id => 1)

    searcher = AssetSearcher.new(:purchased_new => '1', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchased_new)).to be true

    expect(searcher.data).to eq(Asset.where('purchased_new = ?', asset.purchased_new).to_a)
  end

  # #------------------------------------------------------------------------------
  # #
  # # Non-Standard Searches
  # #
  # #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer model' do
    asset = create(:equipment_asset, :manufacturer_model => 'test', :organization_id => 1)

    searcher = AssetSearcher.new(:manufacturer_model => asset.manufacturer_model, :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:manufacturer_model)).to be true

    wildcard_search = "%#{asset.manufacturer_model}%"
    expect(searcher.data).to eq(Asset.where("manufacturer_model LIKE ?", wildcard_search).to_a)
  end

end
