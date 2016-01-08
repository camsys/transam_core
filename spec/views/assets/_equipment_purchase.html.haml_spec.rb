require 'rails_helper'

describe "assets/_equipment_purchase.html.haml", :type => :view do
  it 'purchase info' do
    test_asset = create(:equipment_asset, :purchase_cost => 1234, :purchase_date => Date.new(2010,1,1), :in_service_date => Date.new(2010,3,1), :vendor => create(:vendor), :expected_useful_life => 144)
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content('$1,234')
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content('03/01/2010')
    expect(rendered).to have_content(test_asset.vendor.to_s)
    expect(rendered).to have_content('144 months')

  end
end
