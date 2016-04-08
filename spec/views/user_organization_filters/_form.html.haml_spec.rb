require 'rails_helper'

describe "user_organization_filters/_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:user_organization_filter, UserOrganizationFilter.new)
    render
    
    expect(rendered).to have_field(:user_organization_filter_name)
    expect(rendered).to have_field(:user_organization_filter_description)
    expect(rendered).to have_xpath('//input[@id="user_organization_filter_organization_ids"]')
  end
end
