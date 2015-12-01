require 'rails_helper'

RSpec.describe ScheduleRehabilitationUpdateEvent, :type => :model do

  let(:test_event) { create(:schedule_rehabilitation_update_event) }

  describe 'validations' do
    it 'rebuild_year' do
      test_event.rebuild_year = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(ScheduleRehabilitationUpdateEvent.allowable_params).to eq([:rebuild_year])
  end

  it '#asset_event_type' do
    expect(ScheduleRehabilitationUpdateEvent.asset_event_type).to eq(AssetEventType.find_by_class_name('ScheduleRehabilitationUpdateEvent'))
  end

  it '.get_update' do
    test_event.rebuild_year = 2020
    expect(test_event.get_update).to eq("Scheduled for rehabilitation in FY 20-21.")
  end

  it '.set_defaults' do
    test_event = ScheduleRehabilitationUpdateEvent.new
    year = Date.today.month > 6 ? Date.today.year + 1 : Date.today.year

    expect(test_event.rebuild_year).to eq(year)
    expect(test_event.asset_event_type).to eq(AssetEventType.find_by_class_name('ScheduleRehabilitationUpdateEvent'))
  end

end
