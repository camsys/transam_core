require 'rails_helper'

RSpec.describe DelayedJobPriority, :type => :job do
  it 'changes priority' do
    test_priority = create(:delayed_job_priority, class_name: 'AssetUpdateJob', priority: -10)
    test_asset = create(:buslike_asset)
    test_job = Delayed::Job.enqueue(AssetUpdateJob.new(test_asset.object_key), :priority => 0)
    
    expect(test_job.priority).to eq(-10)
  end
end
