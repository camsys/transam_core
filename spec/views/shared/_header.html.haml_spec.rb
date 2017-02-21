require 'rails_helper'

describe "shared/_header.html.haml", :type => :view do
  it 'navigation' do
    test_user = create(:manager)
    test_filter = create(:user_organization_filter)
    test_org = create(:organization)
    test_user.organizations << [test_user.organization, test_org]
    test_user.update!(user_organization_filter: test_filter)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:session).and_return({:user_organization_filter => test_filter})
    assign(:organization, test_user.organization)
    assign(:organization_list, test_user.organizations.ids)
    create(:equipment_asset)

    render

    expect(rendered).to have_link(test_user.name)
    expect(rendered).to have_link('Logout')
    expect(rendered).to have_link(test_filter.to_s[0..31])
    expect(rendered).to have_xpath('//div[@id="keyword_search_div"]')
  end
end
