require 'rails_helper'

describe "assets/_subtype_details.html.haml", :type => :view do
  it 'info' do
    test_type = create(:asset_subtype)
    assign(:asset_subtype, test_type)
    render

    expect(rendered).to have_content(test_type.description)
  end
end
