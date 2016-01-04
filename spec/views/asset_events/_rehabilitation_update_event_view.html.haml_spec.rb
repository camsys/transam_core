require 'rails_helper'

describe "asset_events/_rehabilitation_update_event_view.html.haml", :type => :view do
  it 'info' do
    test_asset = create(:buslike_asset)
    test_subsystem = create(:asset_subsystem, :asset_type => test_asset.asset_type)
    test_asset.asset_events.create!(attributes_for(:rehabilitation_update_event, :extended_useful_life_months => 12, :extended_useful_life_miles => 1000, :comments => 'test comment 123'))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    test_asset_event_asset_subsystem = create(:asset_event_asset_subsystem, :asset_event_id => test_event.id, :asset_subsystem => test_subsystem, :parts_cost => 2222)
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content('$0')
    expect(rendered).to have_content('$2,222')
    expect(rendered).to have_content('12')
    expect(rendered).to have_content('1000')
    expect(rendered).to have_content(test_subsystem.to_s)
  end
end
