require 'rails_helper'

describe "messages/_response_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:response, Message.new)
    assign(:message, create(:message))
    render

    expect(rendered).to have_field('message_body')
  end
end
