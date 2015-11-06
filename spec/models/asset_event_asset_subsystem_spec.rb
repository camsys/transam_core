require 'rails_helper'

RSpec.describe AssetEventAssetSubsystem, :type => :model do

  let(:test_subsystem) { create(:asset_event_asset_subsystem, :rehabilitation_update_event => create(:buslike_asset).rehabilitation_updates.create!(attributes_for(:rehabilitation_update_event))) }

  describe 'associations' do
    it 'belongs to rehabilitation update event' do
      expect(AssetEventAssetSubsystem.column_names).to include('asset_event_id')
    end
    it 'belongs to an asset subsystem' do
      expect(AssetEventAssetSubsystem.column_names).to include('asset_subsystem_id')
    end
  end

  describe 'validations' do
    it 'must have an asset subsystem' do
      test_subsystem.asset_subsystem = nil
      expect(test_subsystem.valid?).to be false
    end
    it 'must have a rehabilitation event' do
      test_subsystem.rehabilitation_update_event = nil
      expect(test_subsystem.valid?).to be false
    end
    describe 'parts cost' do
      it 'must be a number' do
        test_subsystem.parts_cost = 'abc'
        expect(test_subsystem.valid?).to be false
      end
      it 'must not be negative' do
        test_subsystem.parts_cost = -10
        expect(test_subsystem.valid?).to be false
      end
    end
    describe 'labor cost' do
      it 'must be a number' do
        test_subsystem.labor_cost = 'abc'
        expect(test_subsystem.valid?).to be false
      end
      it 'must not be negative' do
        test_subsystem.labor_cost = -10
        expect(test_subsystem.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(AssetEventAssetSubsystem.allowable_params).to eq([
      :id,
      :asset_subsystem_id,
      :asset_event_id,
      :parts_cost,
      :labor_cost
    ])
  end

  it '.cost' do
    test_subsystem.parts_cost = 13
    test_subsystem.labor_cost = 17
    expect(test_subsystem.cost).to eq(30)
  end
end
