require 'rails_helper'

describe "users/_form.html.haml", :type => :view do
  it 'fields' do
    test_user = create(:manager)
    allow(controller).to receive(:current_user).and_return(test_user)
    assign(:user, User.new)
    render

    expect(rendered).to have_field('user_organization_id')
    expect(rendered).to have_field('user_first_name')
    expect(rendered).to have_field('user_last_name')
    expect(rendered).to have_field('user_email')
    expect(rendered).to have_field('user_title')
    expect(rendered).to have_field('user_external_id')
    expect(rendered).to have_field('user_role_ids')
    expect(rendered).to have_xpath('//input[contains(@id,"user_privilege_ids")]')
    expect(rendered).to have_field('user_phone')
    expect(rendered).to have_field('user_phone_ext')
    expect(rendered).to have_field('user_timezone')
    expect(rendered).to have_field('user_address1')
    expect(rendered).to have_field('user_address2')
    expect(rendered).to have_field('user_city')
    expect(rendered).to have_field('user_state')
    expect(rendered).to have_field('user_zip')
  end
end
