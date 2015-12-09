require 'rails_helper'

describe "vendors/_core_detail_tabs_content.html.haml", :type => :view do
  it 'no assets' do
    assign(:vendor, create(:vendor))
    render

    expect(rendered).to have_content('There are no assets associated with this vendor.')
  end
end
