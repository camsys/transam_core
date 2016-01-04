require 'rails_helper'

describe "assets/_core_index_actions.html.haml", :type => :view do
  it 'actions' do
    test_org = create(:organization)
    assign(:organization_list,[test_org.id, create(:organization).id])
    render

    expect(rendered).to have_link('All agencies')
    expect(rendered).to have_link(test_org.coded_name)
  end
end
