require 'rails_helper'

describe "tasks/_sidebar.html.erb", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    render

    expect(rendered).to have_link('All')
    expect(rendered).to have_link('Started')
    expect(rendered).to have_link('New Task')
  end
end
