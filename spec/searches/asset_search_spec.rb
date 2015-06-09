require 'spec_helper'

RSpec.describe AssetSearcher do
  #------------------------------------------------------------------------------
  #
  # Simple Equality Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by manufacturer' do
    asset = create(:asset, :manufacturer_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:manufacturer_ids => [asset.manufacturer_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:manufacturer_ids)).to be true
    expect(searcher.data).to eq(Asset.where('manufacturer_id = ?', [asset.manufacturer_id]))
  end

  it 'should be able to search by asset type' do
    asset = create(:asset, :asset_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:asset_type_ids => [asset.asset_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:asset_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_type_id = ?', [asset.asset_type_id]))
  end

  it 'should be able to search by asset subtype' do
    asset = create(:asset, :asset_subtype_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:asset_subtype_ids => [asset.asset_subtype_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:asset_subtype_ids)).to be true
    expect(searcher.data).to eq(Asset.where('asset_subtype_id = ?', [asset.asset_subtype_id]))
  end

  it 'should be able to search by condition type' do
    asset = create(:asset, :condition_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:condition_type_ids => [asset.condition_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:condition_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('condition_type_id = ?', [asset.condition_type_id]))
  end

  it 'should be able to search by service status' do
    asset = create(:asset, :service_status_type_id => 1, :organization_id => 1)
    searcher = AssetSearcher.new(:service_status_type_ids => [asset.service_status_type_id], :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:service_status_type_ids)).to be true
    expect(searcher.data).to eq(Asset.where('service_status_type_id = ?', [asset.service_status_type_id]))
  end
  #------------------------------------------------------------------------------
  #
  # Comparator Searches
  #
  #------------------------------------------------------------------------------
  it 'should be able to search by purchase cost' do
    asset = create(:asset, :purchase_cost => 10000, :organization_id => 1)
    lesser = create(:asset, :purchase_cost => 2000, :organization_id => 1)

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchase_cost)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_cost = ?', [asset.purchase_cost]))

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_cost < ?', [asset.purchase_cost]))

    searcher = AssetSearcher.new(:purchase_cost => [asset.purchase_cost], :purchase_cost_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_cost > ?', [asset.purchase_cost]))
  end

  it 'should be able to search by replacement year' do
    asset = create(:asset, :replacement_year => 2020, :organization_id => 1)
    lesser = create(:asset, :replacement_year => 2010, :organization_id => 1)

    searcher = AssetSearcher.new(:replacement_year => asset.replacement_year, :replacement_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('replacement_year = ?', asset.replacement_year))

    searcher = AssetSearcher.new(:replacement_year => asset.replacement_year, :replacement_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('replacement_year < ?', asset.replacement_year))

    searcher = AssetSearcher.new(:replacement_year => asset.replacement_year, :replacement_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('replacement_year > ?', [asset.replacement_year]))
  end

  it 'should be able to search by scheduled replacement year' do
    asset = create(:asset, :scheduled_replacement_year => 2020, :organization_id => 1)
    lesser = create(:asset, :scheduled_replacement_year => 2010, :organization_id => 1)

    searcher = AssetSearcher.new(:scheduled_replacement_year => asset.scheduled_replacement_year, :scheduled_replacement_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:scheduled_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year = ?', asset.scheduled_replacement_year))

    searcher = AssetSearcher.new(:scheduled_replacement_year => scheduled_replacement_year, :scheduled_replacement_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year < ?', asset.scheduled_replacement_year))

    searcher = AssetSearcher.new(:scheduled_replacement_year => asset.scheduled_replacement_year, :scheduled_replacement_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('scheduled_replacement_year > ?', asset.scheduled_replacement_year))
  end

  it 'should be able to search by policy replacement year' do
    asset = create(:asset, :policy_replacement_year => 2020, :organization_id => 1)
    lesser = create(:asset, :policy_replacement_year => 2010, :organization_id => 1)

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :policy_replacement_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:policy_replacement_year)).to be true
    expect(searcher.data).to eq(Asset.where('policy_replacement_year = ?', asset.policy_replacement_year))

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :policy_replacement_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year < ?', asset.policy_replacement_year))

    searcher = AssetSearcher.new(:policy_replacement_year => asset.policy_replacement_year, :scheduled_replacement_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('policy_replacement_year > ?', asset.policy_replacement_year))
  end

  it 'should be able to search by purchase date' do
    asset = create(:asset, :purchase_date => Date.today, :organization_id => 1)
    lesser = create(:asset, :purchase_date => Date.(2000,1,1), :organization_id => 1)

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchase_date)).to be true
    expect(searcher.data).to eq(Asset.where('purchase_date = ?', asset.purchase_date))

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_date < ?', asset.purchase_date))

    searcher = AssetSearcher.new(:purchase_date => asset.purchase_date, :purchase_date_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('purchase_date > ?', asset.purchase_date))
  end

  it 'should be able to search by manufacture year' do
    asset = create(:asset, :manufacture_year => Date.today, :organization_id => 1)
    lesser = create(:asset, :manufacture_year => Date.new(2000,1,1), :organization_id => 1)

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:manufacture_year)).to be true
    expect(searcher.data).to eq(Asset.where('manufacture_year = ?', asset.manufacture_year))

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('manufacture_year < ?', asset.manufacture_year))

    searcher = AssetSearcher.new(:manufacture_year => asset.manufacture_year, :manufacture_year_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('manufacture_year > ?', asset.manufacture_year))
  end

  it 'should be able to search by in service date' do
    asset = create(:asset, :in_service_date => Date.today, :organization_id => 1)
    lesser = create(:asset, :in_service_date => Date.new(2000,1,1), :organization_id => 1)

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '0', :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:in_service_date)).to be true
    expect(searcher.data).to eq(Asset.where('in_service_date = ?', asset.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '-1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('in_service_date < ?', asset.in_service_date))

    searcher = AssetSearcher.new(:in_service_date => asset.in_service_date, :in_service_date_comparator => '1', :organization_id => asset.organization_id )
    expect(searcher.data).to eq(Asset.where('in_service_date > ?', asset.in_service_date))
  end

  #------------------------------------------------------------------------------
  #
  # Checkbox Searches
  #
  #------------------------------------------------------------------------------

  it 'should be able to search by in backlog status' do
    asset = create(:asset, :in_backlog => true, :organization_id => 1)

    searcher = AssetSearcher.new(:in_backlog => asset.in_backlog, :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:in_backlog)).to be true

    expect(searcher.data).to eq(Asset.where('in_backlog = ?', asset.in_backlog))
  end

  it 'should be able to search by in purchased new' do
    asset = create(:asset, :purchased_new => true, :organization_id => 1)

    searcher = AssetSearcher.new(:purchased_new => asset.purchased_new, :organization_id => asset.organization_id )
    expect(searcher.respond_to?(:purchased_new)).to be true

    expect(searcher.data).to eq(Asset.where('purchased_new = ?', asset.purchased_new))
  end

end
