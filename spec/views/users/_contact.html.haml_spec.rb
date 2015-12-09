require 'rails_helper'

describe "users/_contact.html.haml", :type => :view do
  it 'info' do
    test_user = create(:normal_user)
    assign(:user, test_user)
    assign(:organization, test_user.organization)
    render

    expect(rendered).to have_link(test_user.organization.name)
    expect(rendered).to have_content(test_user.organization.to_s)
    expect(rendered).to have_content("(999) 999-9999")
    expect(rendered).to have_content(test_user.phone_ext)
  end
end
