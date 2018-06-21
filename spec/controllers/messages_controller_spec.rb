require 'rails_helper'

RSpec.describe MessagesController, :type => :controller do

  let(:test_msg) { create(:message) }

  before(:each) do
    Organization.destroy_all
    sign_in FactoryBot.create(:admin)
  end

  it 'GET index' do
    new_msg = create(:message, :to_user_id => subject.current_user.id)
    opened_msg = create(:message, :to_user_id => subject.current_user.id, :opened_at => Date.today)
    flagged_msg = create(:message, :to_user_id => subject.current_user.id, :opened_at => Date.today)
    subject.current_user.messages << flagged_msg
    subject.current_user.save!
    sent_msg = create(:message, :user_id => subject.current_user.id)
    get :index, params: {:user_id => subject.current_user.object_key}

    expect(assigns(:messages)).to include(new_msg)
    expect(assigns(:messages)).to include(opened_msg)
    expect(assigns(:messages)).to include(flagged_msg)
    expect(assigns(:messages)).to include(new_msg)
    expect(assigns(:new_messages)).to include(new_msg)
    expect(assigns(:all_messages)).to include(opened_msg)
    expect(assigns(:flagged_messages)).to include(flagged_msg)
    expect(assigns(:sent_messages)).to include(sent_msg)
  end

  it 'POST tag' do
    # tag
    post :tag, params: {:user_id => subject.current_user.object_key, :id => test_msg.object_key}
    expect(test_msg.users).to include(subject.current_user)

    #untag
    post :tag, params: {:user_id => subject.current_user.object_key, :id => test_msg.object_key}
    expect(test_msg.users).not_to include(subject.current_user)
  end

  it 'GET show' do
    test_msg.update!(:to_user => subject.current_user)
    get :show, params: {:user_id => subject.current_user.object_key, :id => test_msg.object_key}

    expect(assigns(:message)).to eq(test_msg)
    expect(assigns(:response).to_json).to eq(Message.new(:organization => assigns(:organization), :user => subject.current_user, :priority_type => assigns(:message).priority_type).to_json)
    expect(assigns(:message).opened_at.strftime('%m/%d/%Y')).to eq(Time.current.strftime('%m/%d/%Y'))
  end

  it 'GET new' do
    receiver = create(:normal_user)
    get :new, params: {:user_id => subject.current_user.object_key, :to_user => receiver.object_key, :subject => 'Test Subject', :body => 'Test Body'}

    expect(assigns(:message_proxy).priority_type_id).to eq(PriorityType.default.id)
    expect(assigns(:message_proxy).to_user_ids).to include(receiver.id)
    expect(assigns(:message_proxy).available_agencies).to eq((assigns(:organization_list)+subject.current_user.organization_ids).uniq)
    expect(assigns(:message_proxy).subject).to eq('Test Subject')
    expect(assigns(:message_proxy).body).to eq('Test Body')
  end

  it 'POST create' do
    # TODO
  end

  it 'POST reply' do
    post :reply, params: {:user_id => subject.current_user.object_key, :id => test_msg.object_key, :message => {:body => 'Reply Body'}}

    expect(assigns(:message)).to eq(test_msg)
    expect(assigns(:new_message).organization).to eq(assigns(:organization))
    expect(assigns(:new_message).user).to eq(subject.current_user)
    expect(assigns(:new_message).priority_type).to eq(assigns(:message).priority_type)
    expect(assigns(:new_message).subject).to eq('Re: '+assigns(:message).subject)
    expect(assigns(:new_message).to_user).to eq(assigns(:message).user)
    expect(assigns(:new_message).body).to eq('Reply Body')
    expect(assigns(:message).responses).to include(assigns(:new_message))
  end

end
