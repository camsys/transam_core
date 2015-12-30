require 'rails_helper'

describe "asset_groups/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:asset_group, create(:asset_group))
    render

    expect(rendered).to have_link('Update this group')
    expect(rendered).to have_link('Remove this group')
  end
end
