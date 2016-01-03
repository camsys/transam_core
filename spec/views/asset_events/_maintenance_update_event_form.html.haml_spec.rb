require 'rails_helper'

describe "asset_events/_maintenance_update_event_form.html.haml", :type => :view do

  class Vehicle < Asset
    has_many :mileage_updates
  end

  it 'fields' do
    assign(:asset, Asset.get_typed_asset(create(:buslike_asset)))
    assign(:asset_event, MaintenanceUpdateEvent.new)
    render

    expect(rendered).to have_field('asset_event_maintenance_type_id')
    expect(rendered).to have_field('asset_event_current_mileage')
    expect(rendered).to have_field('asset_event_event_date')
    expect(rendered).to have_field('asset_event_comments')
  end
end
