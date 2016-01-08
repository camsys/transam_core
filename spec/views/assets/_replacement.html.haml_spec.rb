require 'rails_helper'

describe "assets/_replacement.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset, :policy_replacement_year => 2024, :scheduled_replacement_year => 2025, :scheduled_rehabilitation_year => 2026, :policy_rehabilitation_year => 2027)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content('2024')
    expect(rendered).to have_content('2025')
    expect(rendered).to have_content('2026')
    expect(rendered).to have_content('2027')
  end
end
