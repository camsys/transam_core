require 'rails_helper'

RSpec.describe RehabilitationUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset).rehabilitation_updates.create!(attributes_for(:rehabilitation_update_event)) }

  describe 'associations' do
    it 'has many asset event subsystems' do
      expect(test_event).to have_many(:asset_event_asset_subsystems)
    end
    it 'has many asset subsystems' do
      expect(test_event).to have_many(:asset_subsystems)
    end
  end
  describe 'validations' do
    describe 'extended useful life' do
      it 'must be an integer' do
        test_event.extended_useful_life_months = 1.234
        expect(test_event.valid?).to be false
      end
      it 'cant be a string' do
        test_event.extended_useful_life_months = 'abc'
        expect(test_event.valid?).to be false
      end
      it 'cannot be negative' do
        test_event.extended_useful_life_months = -10
        expect(test_event.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(RehabilitationUpdateEvent.allowable_params).to eq([
      :extended_useful_life_months,
      :asset_event_asset_subsystems_attributes => [AssetEventAssetSubsystem.allowable_params]
    ])
  end
  it '#asset_event_type' do
    expect(RehabilitationUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'RehabilitationUpdateEvent'))
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("Rehabilitation: $#{test_event.cost}: #{test_event.asset_subsystems.join(",")}")
  end

  describe 'costs' do
    describe 'no costs' do
      it '.cost' do
        expect(test_event.cost).to eq(0)
      end
      it '.parts_cost' do
        expect(test_event.parts_cost).to eq(0)
      end
      it '.labor_cost' do
        expect(test_event.labor_cost).to eq(0)
      end
    end
    describe 'all' do
      before(:each) do
        test_subsystem = create(:asset_subsystem)
        create(:asset_event_asset_subsystem, :asset_subsystem => test_subsystem, :rehabilitation_update_event => test_event, :parts_cost => 13, :labor_cost => 17)
      end
      it '.cost' do
        expect(test_event.cost).to eq(30)
      end
      it '.parts_cost' do
        expect(test_event.parts_cost).to eq(13)
      end
      it '.labor_cost' do
        expect(test_event.labor_cost).to eq(17)
      end
    end
  end


  it '.set_defaults' do
    expect(create(:buslike_asset).rehabilitation_updates.new.extended_useful_life_months).to eq(0)
  end


end
