require 'rails_helper'

describe "assets/_asset_compact_datatable.html.haml", :type => :view do
  it 'list' do
    test_asset = create(:buslike_asset, :in_service_date => Date.today - 33.years, :reported_condition_rating => 4, :service_status_type_id => 1)
    render 'assets/asset_compact_datatable', :assets => [test_asset]

    expect(rendered).to have_content(test_asset.asset_subtype.to_s)
    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.description)
    expect(rendered).to have_content((Date.today-33.years).strftime('%m/%d/%Y'))
    expect(rendered).to have_content('33')
    expect(rendered).to have_content("4.0")
    expect(rendered).to have_content(ServiceStatusType.first.to_s)
  end
end
