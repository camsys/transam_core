require 'rails_helper'

describe "asset_events/_maintenance_provider_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:maintenance_provider_update_event, :maintenance_provider_type_id => 1, :comments => 'test comment 123'))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content(MaintenanceProviderType.first.to_s)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content('test comment 123')
  end
end
