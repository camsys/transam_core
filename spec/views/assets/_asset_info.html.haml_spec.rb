require 'rails_helper'

describe "assets/_asset_info.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :purchase_date => Date.today - 14.years, :in_service_date => Date.today - 14.years, :policy_replacement_year => 2026)
    test_asset.service_status_updates.create!(attributes_for(:service_status_update_event, :service_status_type_id => 1))
    test_asset.condition_updates.create!(attributes_for(:condition_update_event, :assessed_rating => 2.0, :event_date => Date.today - 2.days))
    allow(test_asset).to receive(:estimated_condition_rating).and_return(4)
    allow(test_asset).to receive(:estimated_condition_type).and_return(nil)
    allow(test_asset).to receive(:estimated_replacement_year).and_return(2027)
    allow(test_asset).to receive(:estimated_replacement_cost).and_return(4444)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(test_asset.organization.name)
    expect(rendered).to have_content(test_asset.asset_tag)
    expect(rendered).to have_content(test_asset.asset_subtype.name)
    expect(rendered).to have_content(ServiceStatusType.first.to_s)
    # ConditionType.first ("Unknown", ceiling 0.99) is below the model's minimum valid
    # assessed_rating (1.0) - no real rating can ever map to it. Assert against the
    # fixture's own rating instead.
    expect(rendered).to have_content(ConditionType.from_rating(2.0).to_s)
    expect(rendered).to have_content('4.0')
    expect(rendered).to have_content((Date.today-2.days).strftime('%m/%d/%Y'))
    expect(rendered).to have_content('Unknown')
    expect(rendered).to have_content('14 years')
    expect(rendered).to have_content('2026')
    expect(rendered).to have_content('2027')
    expect(rendered).to have_content('$4,444')
  end
end
