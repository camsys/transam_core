require 'rails_helper'

RSpec.describe ActivityJob, :type => :job do

  describe '#initialize' do
    it 'initializes [1st day next month] correctly' do
      job = ActivityJob.new({:due => "1st day next month"})
      expect(job.check()).to eq(true)
    end
    it 'initializes [next tuesday] correctly' do
      job = ActivityJob.new({:due => "next tuesday"})
      expect(job.check()).to eq(true)
    end
    it 'initializes [last day of year] correctly' do
      job = ActivityJob.new({:due => "last day of year"})
      expect(job.check()).to eq(true)
    end
    it 'initializes [Dec 31] correctly' do
      job = ActivityJob.new({:due => "Dec 31"})
      expect(job.check()).to eq(true)
    end
    it 'initializes [12/31/2014] correctly' do
      job = ActivityJob.new({:due => "12/31/2014"})
      expect(job.check()).to eq(true)
    end
    it 'initializes [12/31/2014] [notify] [1 week before] correctly' do
      job = ActivityJob.new({:due => "12/31/2014", :notify => '1 week before'})
      expect(job.check()).to eq(true)
    end
    it 'initializes [12/31/2014] [notify] [1 week before] correctly' do
      job = ActivityJob.new({:due => "12/31/2014", :notify => '2 weeks before'})
      expect(job.check()).to eq(true)
    end
    it 'initializes [12/31/2014] [warn] [1 week before] correctly' do
      job = ActivityJob.new({:due => "12/31/2014", :warn => '1 week before'})
      expect(job.check()).to eq(true)
    end
    it 'initializes [12/31/2014] [warn] [2 weeks  before] correctly' do
      job = ActivityJob.new({:due => "12/31/2014", :warn => '2 weeks before'})
      expect(job.check()).to eq(true)
    end
    it 'fails to initialize [in a blue moon] correctly' do
      job = ActivityJob.new({:due => "in a blue moon"})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Freddies birthday] correctly' do
      job = ActivityJob.new({:due => "Freddies birthday"})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [yesterday] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :notify => 'yesterday'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [morning] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :warn => 'morning'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [a b c] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :alert => 'a b c'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [one week after] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :alert => 'one week after'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [1 coffee before] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :alert => '1 coffee before'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
    it 'fails to initialize [Dec 31] [1 month hence] correctly' do
      job = ActivityJob.new({:due => "Dec 31", :alert => '1 month hence'})
      expect { job.check()}.to raise_error(ArgumentError)
    end
  end

  job = ActivityJob.new({
    :name => 'test_reminder', 
    :activity_description => 'testing',
    :due => 'Dec 31 2015',
    :notify => '1 week before',
    :warn => '2 days before',
    :alert => '1 day after'
    })
  
  describe '#prepare' do
    job.prepare();
    it 'calculates due date/time correctly' do
      expect(job.due_date_time.day).to eq(31)
      expect(job.due_date_time.month).to eq(12)
      expect(job.due_date_time.year).to eq(2015)
      expect(Date.parse(job.due_date_time.to_s)).to eq(Date.parse('2015-12-31'))
    end
    it 'calculates notify date/time correctly' do
      expect(job.notify_date_time.day).to eq(24)
      expect(job.notify_date_time.month).to eq(12)
      expect(job.notify_date_time.year).to eq(2015)
      expect(Date.parse(job.notify_date_time.to_s)).to eq(Date.parse('2015-12-24'))
    end
    it 'calculates warn date/time correctly' do
      expect(job.warn_date_time.day).to eq(29)
      expect(job.warn_date_time.month).to eq(12)
      expect(job.warn_date_time.year).to eq(2015)
      expect(Date.parse(job.warn_date_time.to_s)).to eq(Date.parse('2015-12-29'))
    end
    it 'calculates alert date/time correctly' do
      expect(job.alert_date_time.day).to eq(1)
      expect(job.alert_date_time.month).to eq(1)
      expect(job.alert_date_time.year).to eq(2016)
      expect(Date.parse(job.alert_date_time.to_s)).to eq(Date.parse('2016-1-1'))
    end

  end

end
