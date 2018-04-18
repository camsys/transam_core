require 'rails_helper'

describe "asset_events/_schedule_rehabilitation_update_event_view.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:params).and_return({controller: 'asset_events'})
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:schedule_rehabilitation_update_event, :rebuild_year => 2010, :comments => 'test comment 123'))
    test_event = test_asset.asset_events.last
    assign(:asset_event, test_event)
    render

    expect(rendered).to have_content('FY 10-11')
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content('test comment 123')
  end
end
