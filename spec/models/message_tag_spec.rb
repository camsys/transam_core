require 'rails_helper'

RSpec.describe MessageTag, :type => :model do

  let(:test_org) { create(:organization) }
  let(:test_msg_tag) { MessageTag.create!(:message => create(:message, :organization => test_org), :user => create(:normal_user, :organization => test_org)) }

  describe 'associations' do
    it 'has a user' do
      expect(test_msg_tag).to belong_to(:user)
    end
    it 'has a message' do
      expect(test_msg_tag).to belong_to(:message)
    end
  end

  describe 'validations' do
    it 'must have a user' do
      test_msg_tag.user = nil
      expect(test_msg_tag.valid?).to be false
    end
    it 'must have a message' do
      test_msg_tag.message = nil
      expect(test_msg_tag.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(MessageTag.allowable_params).to eq([])
  end
end
