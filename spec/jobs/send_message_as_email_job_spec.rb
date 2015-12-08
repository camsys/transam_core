require 'rails_helper'

RSpec.describe SendMessageAsEmailJob, :type => :job do
  describe '.run' do
    it 'wrong object key' do
      expect{SendMessageAsEmailJob.new('abcdefgh').run}.to raise_error(RuntimeError, "Can't find Message with object_key abcdefgh")
    end
  end

  it '.prepare' do
    test_msg = create(:message)
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:debug).with("Executing SendMessageAsEmailJob at #{Time.now.to_s} for Message #{test_msg.object_key}"  )
    SendMessageAsEmailJob.new(test_msg.object_key).prepare
  end

  it '.check' do
    expect{SendMessageAsEmailJob.new(nil).check}.to raise_error(ArgumentError, "object_key can't be blank ")
  end
end
