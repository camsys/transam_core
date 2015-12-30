require 'rails_helper'

describe "asset_groups/_summary.html.haml", :type => :view do
  it 'info' do
    test_group = create(:asset_group)
    render 'asset_groups/summary', :asset_group => test_group

    expect(rendered).to have_content(test_group.name)
    expect(rendered).to have_content(test_group.code)
    expect(rendered).to have_content(test_group.description)
  end
end
