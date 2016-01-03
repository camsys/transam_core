require 'rails_helper'

describe "asset_events/_schedule_replacement_update_event_form.html.haml", :type => :view do
  it 'fields' do
    assign(:asset, create(:buslike_asset))
    assign(:asset_event, ScheduleReplacementUpdateEvent.new)
    render

    expect(rendered).to have_field('asset_event_replacement_year')
    expect(rendered).to have_field('asset_event_replacement_reason_type_id')
    expect(rendered).to have_xpath('//input[@id="asset_event_event_date"]')
    expect(rendered).to have_field('asset_event_comments')
  end
end
