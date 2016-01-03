require 'rails_helper'

describe "messages/_message_detail.html.haml", :type => :view do

  before(:each) do
    allow(controller).to receive(:current_user).and_return(create(:admin))
  end

  it 'new mail' do
    test_msg = create(:message)
    render 'messages/message_detail', :msg => test_msg, :filter => MessagesController::ALL_MESSAGE_FILTER

    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content("Sent:")
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_msg.user.name)
    expect(rendered).not_to have_content(test_msg.to_user.name)
  end
  it 'send mail' do
    test_msg = create(:message)
    render 'messages/message_detail', :sent => true, :msg => test_msg, :filter => MessagesController::ALL_MESSAGE_FILTER

    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content("Sent:")
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).not_to have_content(test_msg.user.name)
    expect(rendered).to have_content(test_msg.to_user.name)
    expect(rendered).to have_content('Unopened')
  end
  it 'opened mail' do
    test_msg = create(:message, :opened_at => Date.today+1.day)
    render 'messages/message_detail', :sent => true, :msg => test_msg, :filter => MessagesController::ALL_MESSAGE_FILTER

    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content("Sent:")
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).not_to have_content(test_msg.user.name)
    expect(rendered).to have_content(test_msg.to_user.name)
    expect(rendered).to have_content("Opened:")
    expect(rendered).to have_content((Date.today+1.day).strftime('%m/%d/%Y'))
  end
end
