require 'rails_helper'

describe "uploads/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:upload, create(:upload))
    render

    expect(rendered).to have_link('Resubmit this file')
    expect(rendered).to have_link('Download this file')
    expect(rendered).to have_link('Undo changes')
    expect(rendered).to have_link('Remove this file')
  end
end
