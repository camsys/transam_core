require 'rails_helper'

describe "users/_index_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_org = create(:organization)
    assign(:organization_list, [test_org, create(:organization)])
    assign(:role, Role.first)
    render

    expect(rendered).to have_link('Add a user')
  end
end
