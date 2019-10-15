require 'rails_helper'

describe "assets/_asset_compact_datatable.html.haml", :type => :view do
  it 'list' do
    test_subtype = create(:asset_subtype)
    test_parent_policy = create(:parent_policy, type: test_subtype.asset_type_id, subtype: test_subtype.id)
    test_policy = create(:policy, organization: test_parent_policy.organization, parent: test_parent_policy)
    test_condition_update_event = create(:condition_update_event)
    test_service_status_update_event = create(:service_status_update_event)
    test_asset = create(:transam_asset, asset_subtype: test_subtype, organization: test_policy.organization, purchase_date: Date.today-33.years, in_service_date: Date.today - 33.years, condition_updates: [test_condition_update_event], service_status_updates: [test_service_status_update_event])
    render 'assets/asset_compact_datatable', :assets => [test_asset]

    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.external_id)
    expect(rendered).to have_content(test_asset.organization.short_name)
    expect(rendered).to have_content(test_asset.manufacture_year)
    expect(rendered).to have_content(test_asset.asset_type.to_s)
    expect(rendered).to have_content(test_asset.asset_subtype.to_s)
    expect(rendered).to have_content(test_asset.purchase_cost)
    expect(rendered).to have_content("2.0")
    expect(rendered).to have_content(ServiceStatusType.find_by(id: 2).to_s)
    expect(rendered).to have_content((Date.today-33.years).strftime('%m/%d/%Y'))
  end
end
