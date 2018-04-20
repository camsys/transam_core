require 'rails_helper'

describe "manufacturers/index.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_manufacturer = Manufacturer.first
    assign(:manufacturers, [test_manufacturer])
    assign(:organization, create(:organization))
    assign(:organization_list, [])
    render

    expect(rendered).to have_content(test_manufacturer.id)
    expect(rendered).to have_content(test_manufacturer.name)
    expect(rendered).to have_content(test_manufacturer.code)
  end
end
