require 'rails_helper'

describe "assets/_asset_rehab_details.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:params).and_return({controller: 'assets'})
    test_asset = create(:buslike_asset, :scheduled_replacement_year => 2024, :scheduled_rehabilitation_year => 2025, :scheduled_disposition_year => 2026, :policy_replacement_year => 2027)
    render 'assets/asset_rehab_details', :asset => test_asset

    expect(rendered).to have_content('24-25')
    expect(rendered).to have_content('25-26')
    expect(rendered).to have_content('26-27')
    expect(rendered).to have_content('27-28')
  end
end
