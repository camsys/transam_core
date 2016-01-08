require 'rails_helper'

describe "assets/_equipment_configuration.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:equipment_asset, :manufacturer => create(:manufacturer), :manufacturer_model => 'silverado', :manufacture_year => 2005, :serial_number => 'ABCDE12345')
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(test_asset.description)
    expect(rendered).to have_content('1 piece')
    expect(rendered).to have_content(test_asset.manufacturer.to_s)
    expect(rendered).to have_content('silverado')
    expect(rendered).to have_content('2005')
    expect(rendered).to have_content('ABCDE12345')
  end
end
