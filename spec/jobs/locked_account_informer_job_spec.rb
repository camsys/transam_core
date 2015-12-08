require 'rails_helper'

RSpec.describe LockedAccountInformerJob, :type => :job do

  let(:test_user) { create(:normal_user, :locked_at => Time.now) }

  before(:each) do

  end

  describe '.run' do
    it 'informs' do
      # clear out existing test data
      Message.destroy_all
      User.destroy_all

      #setup users needed for test
      sys_user = create(:normal_user, :first_name => 'system',
      :last_name => 'user',
      :email => 'system.user@example.com')
      test_admin = create(:admin)
      test_user.save!

      LockedAccountInformerJob.new(test_user.object_key).run

      puts Message.all.to_json

      expect(Message.last.user).to eq(sys_user)
      expect(Message.last.to_user).to eq(test_admin)
      expect(Message.last.subject).to eq('User account locked')
      expect(Message.last.body).to eq("#{test_user.name} account was locked at #{test_user.locked_at}")
      expect(Message.last.priority_type).to eq(PriorityType.find_by(:name => 'Normal'))
    end
    it 'wrong object key' do
      expect{LockedAccountInformerJob.new('abcdefgh').run}.to raise_error("Can't find User with object_key abcdefgh")
    end
  end


  it '.prepare' do
    test_user.save!
    allow(Time).to receive(:now).and_return(Time.utc(2000,"jan",1,20,15,1))

    expect(Rails.logger).to receive(:info).with("Executing LockedAccountInformerJob at #{Time.now.to_s} for User #{test_user.object_key}")
    LockedAccountInformerJob.new(test_user.object_key).prepare
  end

  it '.check' do
    expect{LockedAccountInformerJob.new(nil).check}.to raise_error(ArgumentError, "object_key can't be blank ")
  end
end
