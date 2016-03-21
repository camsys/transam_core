require 'rails_helper'

describe "user_organization_filters/_index_actions.html.haml", :type => :view do
  it 'fields' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    render

    expect(rendered).to have_link('Add a filter')
  end
end
