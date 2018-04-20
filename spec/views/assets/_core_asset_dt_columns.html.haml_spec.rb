require 'rails_helper'

describe "assets/_core_asset_dt_columns.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:params).and_return({controller: 'assets'})
    test_asset = create(:buslike_asset, :description => 'test description 123', :parent => create(:buslike_asset), :in_service_date => Date.new(2010, Date.today.month, 1), :reported_condition_rating => 4, :service_status_type_id => 1, :scheduled_rehabilitation_year => 2024, :scheduled_replacement_year => 2025)
    assign(:organization_list, [test_asset.organization, create(:organization)])
    render 'assets/core_asset_dt_columns', :a => test_asset

    expect(rendered).to have_content(test_asset.organization.to_s)
    expect(rendered).to have_content(test_asset.asset_subtype.to_s)
    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.description)
    expect(rendered).to have_link(test_asset.parent.name)
    expect(rendered).to have_content('FY 10-11')
    expect(rendered).to have_content(Date.today.year-2010)
    expect(rendered).to have_content('4.0')
    expect(rendered).to have_content(ServiceStatusType.first.code)
    expect(rendered).to have_content('FY 24-25')
    expect(rendered).to have_content('FY 25-26')
  end
end
