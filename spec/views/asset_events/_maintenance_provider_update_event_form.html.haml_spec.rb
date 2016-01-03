require 'rails_helper'

describe "asset_events/_maintenance_provider_update_event_form.html.haml", :type => :view do
  it 'fields' do
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    assign(:asset_event, MaintenanceProviderUpdateEvent.new(:asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_maintenance_provider_type_id')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
