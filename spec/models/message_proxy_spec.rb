require 'rails_helper'

RSpec.describe MessageProxy, :type => :model do

  let(:test_proxy) { MessageProxy.new(:priority_type_id => 1, :subject => 'Test Subject', :body => 'Test Message', :to_user_ids => [create(:normal_user)]) }

  describe 'valiadtions' do
    it 'must have a priority type' do
      expect(test_proxy.valid?).to be true
      test_proxy.priority_type_id = nil
      expect(test_proxy.valid?).to be false
    end
    it 'must have a subject' do
      test_proxy.subject = nil
      expect(test_proxy.valid?).to be false
    end
    it 'must have a body' do
      test_proxy.body = nil
      expect(test_proxy.valid?).to be false
    end
    describe 'must be sent to at least one user' do
      it 'send individually' do
        test_proxy.to_user_ids = []
        expect(test_proxy.valid?).to be false
      end
      it 'send to group' do
        test_proxy.send_to_group = '1'

        test_proxy.to_user_ids = []
        test_proxy.group_roles = [1]
        expect(test_proxy.valid?).to be true
        test_proxy.group_roles = []
        expect(test_proxy.valid?).to be false
      end
    end
  end

  it '#allowable_params' do
    expect(MessageProxy.allowable_params).to eq([
      :priority_type_id,
      :subject,
      :body,
      :send_to_group,
      :to_user_ids => [],
      :group_roles => [],
      :group_agencys => []
    ])
  end

  it '.initialize' do
    test_proxy = MessageProxy.new

    expect(test_proxy.send_to_group).to eq('0')
    expect(test_proxy.to_user_ids).to eq([])
    expect(test_proxy.group_roles).to eq([])
    expect(test_proxy.group_agencys).to eq([])
  end
end
