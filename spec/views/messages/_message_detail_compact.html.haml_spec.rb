require 'rails_helper'

describe "messages/_message_detail_compact.html.haml", :type => :view do

  before(:each) do
    allow(controller).to receive(:current_user).and_return(create(:admin))
  end

  it 'new mail' do
    test_msg = create(:message)
    render 'messages/message_detail_compact', :msg => test_msg

    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_msg.user.name)
    expect(rendered).not_to have_content(test_msg.to_user.name)
  end
  it 'send mail' do
    test_msg = create(:message)
    render 'messages/message_detail_compact', :sent => true, :msg => test_msg

    expect(rendered).to have_content(test_msg.subject)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).not_to have_content(test_msg.user.name)
    expect(rendered).to have_content(test_msg.to_user.name)
  end
end
