require 'rails_helper'

RSpec.describe EarlyDispositionRequestUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset).early_disposition_requests.create!(attributes_for(:early_disposition_request_update_event)) }

  describe 'validations' do
    it 'must have comments' do
      test_event.comments = nil
      expect(test_event.valid?).to be false
    end
  end

  it '#allowable_params' do
    expect(EarlyDispositionRequestUpdateEvent.allowable_params).to eq([:state, :document])
  end
  it '#asset_event_type' do
    expect(EarlyDispositionRequestUpdateEvent.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'EarlyDispositionRequestUpdateEvent'))
  end

  describe "state machine" do 
    it "has a state machine" do 
      expect(EarlyDispositionRequestUpdateEvent.respond_to?(:state_machine)).to be(true)
    end

    it "#state_names" do 
      expect(EarlyDispositionRequestUpdateEvent.state_names).to match_array(["new", "approved", "rejected", "transfer_approved"])
    end

    it '#event_names' do
      expect(EarlyDispositionRequestUpdateEvent.event_names).to match_array(["approve", "reject", "approve_via_transfer"])
    end
  end

  it '.get_update' do
    expect(test_event.get_update).to eq("Early disposition request was made")
  end

  it '.get_latest_update' do
    test_event.state = 'new'
    expect(test_event.get_latest_update).to eq("Early disposition request was made")
    test_event.state = 'transfer_approved'
    expect(test_event.get_latest_update).to eq("Early disposition request was approved via transfer")
    test_event.state = 'rejected'
    expect(test_event.get_latest_update).to eq("Early disposition request was rejected")
    test_event.state = 'approved'
    expect(test_event.get_latest_update).to eq("Early disposition request was approved")
  end

  it '.set_defaults' do
    new_event = create(:buslike_asset).early_disposition_requests.new
    expect(new_event.event_date).to eq(Date.today)
    expect(new_event.state).to eq('new')
    expect(new_event.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'EarlyDispositionRequestUpdateEvent'))
  end

  describe "state checks" do 
    it '.is_new?' do 
      test_event.state = 'new'
      expect(test_event.is_new?).to be(true)
    end
    it '.is_unconditional_approved?' do 
      test_event.state = 'approved'
      expect(test_event.is_unconditional_approved?).to be(true)
    end
    it '.is_approved?' do 
      test_event.state = 'approved'
      expect(test_event.is_approved?).to be(true)
      test_event.state = 'transfer_approved'
      expect(test_event.is_approved?).to be(true)
    end
    it '.is_rejected?' do 
      test_event.state = 'rejected'
      expect(test_event.is_rejected?).to be(true)
    end
  end

  describe "notifications" do
    it '#workflow_notification_enabled?' do 
      expect(EarlyDispositionRequestUpdateEvent.workflow_notification_enabled?).to be(true)
    end

    describe '.event_in_passive_tense' do 
      it "new in passive tense is created" do 
        expect(test_event.event_in_passive_tense(:new)).to eq('created')
      end

      it "reject in passive tense is rejected" do
        expect(test_event.event_in_passive_tense(:reject)).to eq('rejected')
      end

      it "approve in passive tense is approved" do
        expect(test_event.event_in_passive_tense(:approve)).to eq('approved')
      end

      it "approve_via_transfer in passive tense is transfer approved" do
        expect(test_event.event_in_passive_tense(:approve_via_transfer)).to eq('approved via transfer')
      end
    end

    describe "sending notifications" do 
      before(:all) do
        User.delete_all

        @new_event = create(:early_disposition_request_update_event)
        @new_event.creator = create(:normal_user)
        @new_event.save
        @manager = create(:manager)
      end
      
      describe '.default_notification_recipients' do
    
        it "new to notify managers" do 
          expect(@new_event.default_notification_recipients(:new)).to eq([@manager])
        end

        it "approve to notify creator" do
          expect(@new_event.default_notification_recipients(:approve)).to match_array([@new_event.creator])
        end

        it "reject to notify creator" do
          expect(@new_event.default_notification_recipients(:reject)).to match_array([@new_event.creator])
        end

        it "approve_via_transfer to notify creator" do
          expect(@new_event.default_notification_recipients(:approve_via_transfer)).to match_array([@new_event.creator])
        end
      end

      describe '.notify_event_by' do
        before(:all) do 
          @sender = create(:manager)
        end

        it "send notifications to right people" do
          expect{@new_event.notify_event_by(@sender, :approve)}.to change{UserNotification.count}.by(1) #one to creator
        end

        it "shouldn't send to sender" do 
          @new_event.notify_event_by(@sender, :approve)
          expect(Message.where(to_user: @sender)).to be_empty
        end
      end
    end
  end
end
