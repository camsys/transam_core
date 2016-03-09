require 'rails_helper'

describe "asset_events/_rehabilitation_update_event_form.html.haml", :type => :view do

  it 'fields' do
    allow_any_instance_of(Asset).to receive(:type_of?).and_return(true)

    test_asset = Asset.get_typed_asset(create(:buslike_asset))
    create(:asset_subsystem, :asset_type => test_asset.asset_type)
    test_asset.asset_events.create!(attributes_for(:rehabilitation_update_event))
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
