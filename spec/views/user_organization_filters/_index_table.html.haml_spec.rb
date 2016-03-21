require 'rails_helper'

describe "user_organization_filters/_index_table.html.haml", :type => :view do
  it 'fields' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    test_filter = create(:user_organization_filter)
    assign(:user_organization_filters, UserOrganizationFilter.where(id: test_filter.id))
    render 'user_organization_filters/index_table', :show_actions => 0
    
    expect(rendered).to have_content(test_filter.object_key)
    expect(rendered).to have_content(test_filter.name)
    expect(rendered).to have_content(test_filter.description)
    expect(rendered).to have_content(test_filter.user.to_s)
  end
end
