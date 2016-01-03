require 'rails_helper'

describe "uploads/_update_events.html.haml", :type => :view do
  it 'info' do
    test_upload = create(:upload)
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:condition_update_event, :asset => test_asset, :upload => test_upload, :comments => 'test comment 123'))
    test_event = test_asset.asset_events.last
    assign(:upload, test_upload)
    render

    expect(rendered).to have_link(test_event.asset.to_s)
    expect(rendered).to have_link(test_event.asset_event_type.description)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_event.get_update)
    expect(rendered).to have_content('test comment 123')
  end
end
