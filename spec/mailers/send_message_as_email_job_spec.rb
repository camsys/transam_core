require 'rails_helper'

RSpec.describe SendMessageAsEmailJob, :type => :mailer do
  pending 'There is an obscure issue with actionmailer/mail that is causing a frozen string error'
  let(:msg) {create(:message)}


  describe '#perform' do
    xit 'queues an email to a message\'s target if they have elected to receive email' do
      msg.to_user.update_attributes(:notify_via_email => true)
      expect{SendMessageAsEmailJob.new(msg.object_key).perform}.to change{ActionMailer::Base.deliveries.count}.by(1)

    end

    xit 'does nothing if passed nonsense' do
      expect{SendMessageAsEmailJob.new("IAMNONSENSE").perform}.to change{ActionMailer::Base.deliveries.count}.by(0)
    end
  end
end
