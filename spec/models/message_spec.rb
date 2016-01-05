require 'rails_helper'

RSpec.describe Message, :type => :model do

  let(:msg) { build(:message)}
  let(:user1) { build(:normal_user)}
  let(:user2) { build(:manager)}

  describe '#response_count' do

    it '#response_count works as expected' do
      msg = build(:message)
      msg2 = build(:message)
      msg3 = build(:message)
      msg.responses << [msg2, msg3]
      expect(msg.response_count).to eql(2)
    end

    it 'is 0 for a new message' do
      expect(msg.response_count).to eq(0)
    end

    it 'is 1 for a message with a single response' do
      msg.save
      msg.responses.create(attributes_for(:message))
      expect(msg.response_count).to eq(1)
    end

    it 'is 2 for a message which has a response to a response' do
      msg.save
      m2 = msg.responses.build(attributes_for(:message))
      m2.user = user2
      m2.to_user user1
      m2.organization = msg.organization
      m2.save
      m3= m2.responses.build(attributes_for(:message))
      m3.user = user1
      m3.to_user user2
      m3.organization = msg.organization
      m3.save

      expect(msg.response_count).to eq(2)
    end
  end


end
