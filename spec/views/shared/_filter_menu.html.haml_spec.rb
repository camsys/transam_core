require 'rails_helper'

describe "shared/_filter_menu.html.haml", :type => :view do
  it 'links' do
    test_user = create(:admin)
    test_filter = create(:user_organization_filter)
    test_user.user_organization_filters << test_filter
    test_user.update!(user_organization_filter: test_filter)

    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:organization_list, [1,2])

    render

    expect(rendered).to have_link(test_filter.name)
    expect(rendered).to have_link('Manage Filters')
    expect(rendered).to have_link('New Filter')
  end
end
