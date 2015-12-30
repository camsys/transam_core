require 'rails_helper'

describe "asset_groups/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:asset_group, AssetGroup.new)
    render

    expect(rendered).to have_xpath('//input[@id="use_cached_assets"]')
    expect(rendered).to have_field('asset_group_name')
    expect(rendered).to have_field('asset_group_code')
    expect(rendered).to have_field('asset_group_description')
  end
end
