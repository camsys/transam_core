require 'rails_helper'

describe "vendors/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_vendor = create(:vendor)
    assign(:vendors, [test_vendor])
    render

    expect(rendered).to have_content(test_vendor.object_key)
    expect(rendered).to have_content(test_vendor.name)
  end
end
