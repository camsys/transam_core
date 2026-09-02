require 'rails_helper'

describe "asset_events/_rehabilitation_update_event_form.html.haml", :type => :view do

  it 'fields' do
    test_asset = create(:buslike_asset)
    create(:asset_subsystem, :asset_type => test_asset.asset_subtype.asset_type)
    test_asset.asset_events.create!(attributes_for(:rehabilitation_update_event, :transam_asset => test_asset))
    test_event = AssetEvent.as_typed_event(test_asset.asset_events.last)
    assign(:asset, test_asset)
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_field('asset_event_asset_event_asset_subsystems_attributes_0_parts_cost')
    expect(rendered).to have_field('asset_event_asset_event_asset_subsystems_attributes_0_labor_cost')
    expect(rendered).to have_field('asset_event_extended_useful_life_months')
    expect(rendered).to have_field('asset_event_extended_useful_life_miles')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
