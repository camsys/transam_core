require 'rails_helper'

RSpec.describe EarlyDispositionRequestUpdateEvent, :type => :model do

  let(:test_event) { create(:buslike_asset).early_disposition_requests.create!(attributes_for(:early_disposition_request_update_event)) }

  describe 'validations' do
    it 'must have a document' do
      new_event = build_stubbed(:early_disposition_request_update_event, :document => nil)
      expect(new_event.valid?).to be false
    end
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

  it '.set_defaults' do
    new_event = create(:buslike_asset).early_disposition_requests.new
    expect(new_event.event_date).to eq(Date.today)
    expect(new_event.state).to eq('new')
    expect(new_event.asset_event_type).to eq(AssetEventType.find_by(:class_name => 'EarlyDispositionRequestUpdateEvent'))
  end
end
