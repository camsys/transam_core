require 'rails_helper'

describe "messages/index.html.haml", :type => :view do
  it 'links and messages' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:new_messages, [])
    assign(:flagged_messages, [])
    assign(:all_messages, [])
    assign(:sent_messages, [])
    render

    expect(rendered).to have_link('Refresh')
    expect(rendered).to have_link('Compose')
    expect(rendered).to have_link('New')
    expect(rendered).to have_link('Flagged')
    expect(rendered).to have_link('Inbox')
    expect(rendered).to have_link('Sent')
    expect(rendered).to have_content('No new messages')
    expect(rendered).to have_content('No flagged messages')
    expect(rendered).to have_content('No messages')
    expect(rendered).to have_content('No sent messages')
  end
end
