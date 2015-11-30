require 'rails_helper'

RSpec.describe Activity, :type => :model do

  let(:test_activity) { create(:activity) }

  describe 'association' do
    it 'has an org type' do
      expect(Activity.column_names).to include('organization_type_id')
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
    it 'must have a start' do
      test_activity.start = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a due' do
      test_activity.due = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a notify' do
      test_activity.notify = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a warn' do
      test_activity.warn = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have an alert' do
      test_activity.alert = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have an escalate' do
      test_activity.escalate = nil
      expect(test_activity.valid?).to be false
    end
    it 'must have a job name' do
      test_activity.job_name = nil
      expect(test_activity.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(Activity.allowable_params).to eq([
      :organization_type_id,
      :name,
      :description,
      :start,
      :due,
      :notify,
      :notify_complete,
      :warn,
      :warn_complete,
      :alert,
      :alert_complete,
      :escalate,
      :escalate_complete,
      :job_name,
      :active
    ])
  end

  it '.due_datetime' do
    test_activity.due = "12/24/20"

    expect(test_activity.due_datetime).to eq(Chronic.parse(Date.new(2020,12,24)))
  end
  it '.to_s' do
    expect(test_activity.to_s).to eq(test_activity.name)
  end
  it '.set_defaults' do
    expect(Activity.new.active).to be true
  end
end
