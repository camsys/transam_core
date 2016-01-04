require 'rails_helper'

describe "assets/_asset_condition_details.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :in_service_date => Date.today-14.years, :reported_condition_type_id => 1)
    render 'assets/asset_condition_details', :asset => test_asset

    expect(rendered).to have_content(test_asset.in_service_date.strftime('%m/%d/%Y'))
    expect(rendered).to have_content('14 yrs')
    expect(rendered).to have_content(ConditionType.first.to_s)
  end
end
