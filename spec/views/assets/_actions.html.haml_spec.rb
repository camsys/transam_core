require 'rails_helper'

describe "assets/_actions.html.haml", :type => :view do

  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:organization, create(:organization))
    assign(:asset, create(:buslike_asset))
    render

    expect(rendered).to have_link('Update the master record')
    expect(rendered).to have_link('Make a copy')
    expect(rendered).to have_link('Record final disposition')
    expect(rendered).to have_link('Remove this asset')
  end
end
