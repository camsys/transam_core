require 'rails_helper'

describe "activities/index.html.haml", :type => :view do
  it 'no activities' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:activities, [])
    render

    expect(rendered).to have_content('No matching activities found')
  end
end
