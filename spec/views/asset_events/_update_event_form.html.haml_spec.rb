require 'rails_helper'

describe "asset_events/_update_event_form.html.haml", :type => :view do
  it 'fields' do
    test_asset = create(:buslike_asset)
    assign(:asset, test_asset)
    assign(:asset_event, ConditionUpdateEvent.new(:asset => test_asset))
    render

    expect(rendered).to have_xpath('//input[@id="event_type"]')
  end
end
