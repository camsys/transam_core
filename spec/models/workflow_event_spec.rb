require 'rails_helper'

RSpec.describe WorkflowEvent, :type => :model do

  let(:test_event) { WorkflowEvent.new }

  it 'is an event of an object' do
    expect(test_event).to belong_to(:accountable)
  end
  it 'must have a creator' do
    expect(test_event).to belong_to(:creator)
    test_event.creator = nil
    expect(test_event.valid?).to be false
  end
  it 'must have an event type' do
    test_event.event_type = nil
    expect(test_event.valid?).to be false
  end

  it '#allowable_params' do
    expect(WorkflowEvent.allowable_params).to eq([
      :event_type,
      :accountable_id,
      :accountable_type,
      :created_by_id
    ])
  end

end
