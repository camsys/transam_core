require 'rails_helper'

RSpec.describe ScheduleReplacementUpdateEvent, :type => :model do

  let(:test_event) { create(:schedule_replacement_update_event) }

  describe 'associations' do
    it 'has a replacement reason' do
      expect(ScheduleReplacementUpdateEvent.column_names).to include('replacement_reason_type_id')
    end
  end

  describe 'validations' do
    describe 'replacement year' do
      it 'must be year' do
        test_event.replacement_year = 'abcde'
        expect(test_event.valid?).to be false
      end
      it 'cannot be more than 10 years ago' do
        test_event.replacement_year = 1900
        expect(test_event.valid?).to be false
      end
    end
    it 'must have a replacement reason' do
      test_event.replacement_reason_type = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(ScheduleReplacementUpdateEvent.allowable_params).to eq([:replacement_reason_type_id, :replacement_year])
  end

  it '#asset_event_type' do
    expect(ScheduleReplacementUpdateEvent.asset_event_type).to eq(AssetEventType.find_by_class_name('ScheduleReplacementUpdateEvent'))
  end

  it '.get_update' do
    test_event.replacement_year = 2020
    expect(test_event.get_update).to eq("Scheduled for replacement in FY 20-21. Reason: #{test_event.replacement_reason_type}.")
  end

  it '.set_defaults' do
    test_event = ScheduleReplacementUpdateEvent.new
    year = Date.today.month > 6 ? Date.today.year + 1 : Date.today.year

    expect(test_event.replacement_year).to eq(year)
    expect(test_event.asset_event_type).to eq(AssetEventType.find_by_class_name('ScheduleReplacementUpdateEvent'))
    expect(test_event.replacement_reason_type).to eq(ReplacementReasonType.find_by(:name => "Reached policy EUL"))
  end

end
