require 'rails_helper'

RSpec.describe ScheduleDispositionUpdateEvent, :type => :model do

  let(:test_event) { create(:schedule_disposition_update_event) }

  describe 'validations' do
    it 'has a year' do
      expect(ScheduleDispositionUpdateEvent.column_names).to include('disposition_year')
    end
  end

  it '#allowable_params' do
    expect(ScheduleDispositionUpdateEvent.allowable_params).to eq([:disposition_year])
  end
  it '#asset_event_type' do
    expect(ScheduleDispositionUpdateEvent.asset_event_type).to eq(AssetEventType.find_by_class_name('ScheduleDispositionUpdateEvent'))
  end


  it '.get_update' do
    test_event.disposition_year = 2020
    expect(test_event.get_update).to eq("Scheduled for disposition in FY 20-21")
  end

  it '.set_defaults' do
    year = Date.today.month > 6 ? Date.today.year + 1 : Date.today.year
    expect(ScheduleDispositionUpdateEvent.new.disposition_year).to eq(year)
  end
end
