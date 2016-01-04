require 'rails_helper'

describe "asset_events/_location_update_event_view.html.haml", :type => :view do

  class Vehicle < Asset; end

  it 'info' do
    test_asset = create(:buslike_asset)
    test_parent = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:location_update_event, :parent_id => test_parent.id, :comments => 'test comment 123'))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content(test_event.parent.description)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content('test comment 123')
  end
end
