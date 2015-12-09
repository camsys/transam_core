require 'rails_helper'

describe "users/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_user = create(:normal_user)
    assign(:users, [test_user])
    render

    expect(rendered).to have_content(test_user.object_key)
    expect(rendered).to have_link(test_user.first_name)
    expect(rendered).to have_content(test_user.last_name)
  end
end
