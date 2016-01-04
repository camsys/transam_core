require 'rails_helper'

describe "assets/_asset_rehab_details.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :scheduled_replacement_year => 2024, :scheduled_rehabilitation_year => 2025, :scheduled_disposition_year => 2026, :policy_replacement_year => 2027)
    render 'assets/asset_rehab_details', :asset => test_asset

    expect(rendered).to have_content('FY 24-25')
    expect(rendered).to have_content('FY 25-26')
    expect(rendered).to have_content('FY 26-27')
    expect(rendered).to have_content('FY 27-28')
  end
end
