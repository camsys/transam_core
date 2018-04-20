require 'rails_helper'

describe "asset_events/_schedule_rehabilitation_update_event_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:params).and_return({controller: 'asset_events'})
    assign(:asset, create(:buslike_asset))
    assign(:asset_event, ScheduleRehabilitationUpdateEvent.new)
    render

    expect(rendered).to have_field('asset_event_rebuild_year')
    expect(rendered).to have_xpath('//input[@id="asset_event_event_date"]')
    expect(rendered).to have_field('asset_event_comments')
  end
end
