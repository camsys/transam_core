require 'rails_helper'

RSpec.describe ActivityJob, :type => :job do

  describe '#initialize' do
    it 'initializes correctly' do
      job = ActivityJob.new({:context => create(:activity)})
      expect(job.check()).to eq(true)
    end
    it 'fails to initialize if no context' do
      job = ActivityJob.new()
      expect { job.check()}.to raise_error(ArgumentError)
    end
  end

  it '.clean_up' do
    test_activity = create(:activity)
    job = ActivityJob.new({:context => test_activity})
    job.check
    job.clean_up
    test_activity.reload

    expect(test_activity.last_run).not_to be nil
  end
end
