require 'rails_helper'

describe "activities/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:activity, create(:activity))
    render

    expect(rendered).to have_link('Update this activity')
    expect(rendered).to have_link('Remove this activity')
  end
end
