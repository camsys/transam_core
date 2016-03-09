require 'rails_helper'

describe "asset_events/_maintenance_update_event_view.html.haml", :type => :view do
  
  it 'info' do
    test_asset = create(:buslike_asset)
    test_type = create(:maintenance_type)
    test_asset.asset_events.create!(attributes_for(:maintenance_update_event, :maintenance_type_id => test_type.id, :current_mileage => 44444, :comments => 'test comment 123'))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    assign(:asset, Asset.get_typed_asset(test_asset))
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content(test_type.to_s)
    expect(rendered).to have_content('44,444')
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content('test comment 123')
  end
end
