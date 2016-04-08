require 'rails_helper'

describe "shared/_header.html.haml", :type => :view do
  it 'navigation' do
    test_user = create(:manager)
    test_filter = create(:user_organization_filter)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:session).and_return({:user_organization_filter => test_filter})
    assign(:organization, create(:organization))
    render

    expect(rendered).to have_link(test_user.name)
    expect(rendered).to have_link('Logout')
    expect(rendered).to have_link(test_filter.to_s)
    expect(rendered).to have_field('search_text')
  end
end
