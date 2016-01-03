require 'rails_helper'

describe "asset_events/_service_status_update_event_form.html.haml", :type => :view do
  it 'fields' do
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    assign(:asset_event, ServiceStatusUpdateEvent.new(:asset => test_asset))
    render

    expect(rendered).to have_field('asset_event_service_status_type_id')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
