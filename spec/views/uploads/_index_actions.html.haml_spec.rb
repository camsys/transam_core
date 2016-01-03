require 'rails_helper'

describe "uploads/_index_actions.html.haml", :type => :view do
  it 'links' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    render

    expect(rendered).to have_link('Create a new Template')
    expect(rendered).to have_link('Upload a Template')
    expect(rendered).to have_link('All statuses')
    expect(rendered).to have_link(FileStatusType.first.to_s)
  end
end
