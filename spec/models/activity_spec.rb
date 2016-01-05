require 'rails_helper'

RSpec.describe Activity, :type => :model do

  let(:test_activity) { create(:activity) }

  describe 'association' do
    it 'has a frequenct type' do
      expect(Activity.column_names).to include('frequency_type_id')
    end
  end

  describe 'validations' do
    it 'must have a name' do
      test_activity.name = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a descrip' do
      test_activity.description = nil
      expect(test_activity.valid?).to be false
    end
    describe 'frequency quantity' do
      it 'must exist' do
        test_activity.frequency_quantity = nil
        expect(test_activity.valid?).to be false
      end
      it 'must be a number' do
        test_activity.frequency_quantity = 'abc'
        expect(test_activity.valid?).to be false
      end
      it 'must be greater than 0' do
        test_activity.frequency_quantity = 0
        expect(test_activity.valid?).to be false
      end
    end
    it 'must have a frequency type' do
      test_activity.frequency_type = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a job name' do
      test_activity.job_name = nil
      expect(test_activity.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Activity.allowable_params).to eq([
      :name,
      :description,
      :show_in_dashboard,
      :system_activity,
      :start_date,
      :end_date,
      :frequency_quantity,
      :frequency_type_id,
      :execution_time,
      :job_name,
      :active
    ])
  end

  describe '.operational' do
    it 'no start date' do
      expect(test_activity.operational?).to be true
    end
    it 'no end date' do
      test_activity.start_date = Date.today - 3.days
      expect(test_activity.operational?).to be false
    end
    it 'end date is after start' do
      test_activity.start_date = Date.today - 3.days
      test_activity.end_date = Date.today - 5.days
      expect(test_activity.operational?).to be false
    end
    it 'today is not within range' do
      test_activity.start_date = Date.today - 3.days
      test_activity.end_date = Date.today - 1.days
      expect(test_activity.operational?).to be false
    end
    it 'today is within range' do
      test_activity.start_date = Date.today - 3.days
      test_activity.end_date = Date.today + 3.days
      expect(test_activity.operational?).to be true
    end
  end
  it '.to_s' do
    expect(test_activity.to_s).to eq(test_activity.name)
  end
  it '.schedule' do
    expect(test_activity.schedule).to eq("1 #{FrequencyType.first.to_s}s at one hour")
  end
  it '.frequency' do
    pending('TODO')
    fail
  end
  it '.job' do
    expect(test_activity.job.to_json).to eq(ActivityJob.new(:context => test_activity).to_json)
  end

  it '.set_defaults' do
    expect(Activity.new.active).to be true
    expect(Activity.new.show_in_dashboard).to be true
    expect(Activity.new.system_activity).to be false
    expect(Activity.new.frequency_quantity).to eq(1)
  end
end
