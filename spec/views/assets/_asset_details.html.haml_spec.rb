require 'rails_helper'

describe "assets/_asset_details.html.haml", :type => :view do
  it 'no asset' do
    render 'assets/asset_details', :asset => nil

    expect(rendered).to have_content('No asset found')
  end
  it 'info' do
    test_asset = create(:buslike_asset, :service_status_type_id => 1, :parent => create(:buslike_asset), :manufacturer => Manufacturer.first)
    render 'assets/asset_details', :asset => test_asset

    expect(rendered).to have_link(test_asset.organization.short_name)
    expect(rendered).to have_content(test_asset.description)
    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.manufacturer.code)
    expect(rendered).to have_content(test_asset.asset_type.to_s)
    expect(rendered).to have_content(test_asset.asset_subtype.to_s)
    expect(rendered).to have_content(ServiceStatusType.first.to_s)
    expect(rendered).to have_link(test_asset.parent.to_s)
  end
end
