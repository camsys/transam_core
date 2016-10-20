require 'rails_helper'

describe "user_organization_filters/_actions.html.haml", :type => :view do
  it 'links' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    assign(:user_organization_filter, create(:user_organization_filter, :created_by_user_id => test_user.id))
    render

    expect(rendered).to have_link('Set as current filter')
    expect(rendered).to have_link('Update this filter')
    expect(rendered).to have_link('Remove this filter')
  end
end
