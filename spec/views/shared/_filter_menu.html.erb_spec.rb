require 'rails_helper'

describe "shared/_filter_menu.html.erb", :type => :view do
  it 'links' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_filter = create(:user_organization_filter)
    render

    expect(rendered).to have_link(test_filter.name)
    expect(rendered).to have_link('Manage Filters')
    expect(rendered).to have_link('New Filter')
  end
end
