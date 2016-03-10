require 'rails_helper'

describe "assets/_asset_info.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :in_service_date => Date.today - 14.years, :service_status_type_id => 1, :reported_condition_type_id => 1, :reported_condition_date => Date.today - 2.days, :estimated_condition_rating => 4, :policy_replacement_year => 2026, :estimated_replacement_year => 2027, :estimated_replacement_cost => 4444)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(test_asset.organization.name)
    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.asset_subtype.name)
    expect(rendered).to have_content(ServiceStatusType.first.to_s)
    expect(rendered).to have_content(ConditionType.first.to_s)
    expect(rendered).to have_content('4.0')
    expect(rendered).to have_content((Date.today-2.days).strftime('%m/%d/%Y'))
    expect(rendered).to have_content('Unknown')
    expect(rendered).to have_content('14 years')
    expect(rendered).to have_content('2026')
    expect(rendered).to have_content('2027')
    expect(rendered).to have_content('$4,444')
  end
end
