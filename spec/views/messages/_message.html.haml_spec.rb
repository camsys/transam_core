require 'rails_helper'

describe "messages/_message.html.haml", :type => :view do

  let(:test_user) { create(:admin) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(test_user)
  end

  it 'all' do
    test_msg = create(:message)
    assign(:message, test_msg)
    render

    expect(rendered).to have_link('Messages')
    expect(rendered).to have_link('Compose')
    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content("Sent:")
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_msg.body)
    expect(rendered).to have_content('Unopened')
  end

  it 'not to me' do
    test_msg = create(:message)
    assign(:message, test_msg)
    render

    expect(rendered).to have_content("To: #{test_msg.to_user.name}")
  end
  it 'to me' do
    test_msg = create(:message, :to_user => test_user)
    assign(:message, test_msg)
    assign(:response, Message.new)
    render
    expect(rendered).to have_content("From: #{test_msg.user.name}")
  end
  it 'opened mail' do
    test_msg = create(:message, :opened_at => Date.today+1.day)
    assign(:message, test_msg)
    render

    expect(rendered).to have_content("Opened:")
    expect(rendered).to have_content((Date.today+1.day).strftime('%m/%d/%Y'))
  end
end
