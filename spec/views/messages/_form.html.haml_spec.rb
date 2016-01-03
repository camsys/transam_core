require 'rails_helper'

describe "messages/_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:message_proxy, MessageProxy.new)
    render

    expect(rendered).to have_xpath('//input[@id="message_proxy_send_to_group"]')
    expect(rendered).to have_field('message_proxy_to_user_ids')
    expect(rendered).to have_field('message_proxy_group_agencys')
    expect(rendered).to have_field('message_proxy_group_roles')
    expect(rendered).to have_field('switch-mode')
    expect(rendered).to have_field('message_proxy_subject')
    expect(rendered).to have_field('message_proxy_priority_type_id')
    expect(rendered).to have_field('message_proxy_body')
  end
end
