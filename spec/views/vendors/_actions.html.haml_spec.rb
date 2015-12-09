require 'rails_helper'

describe "vendors/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:vendor, create(:vendor))
    render

    expect(rendered).to have_link("Update this vendor")
    expect(rendered).to have_link("Remove this vendor")
  end
end
