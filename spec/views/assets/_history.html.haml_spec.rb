require 'rails_helper'

describe "assets/_history.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:condition_update_event, :comments => 'test comment 123'))
    assign(:asset, test_asset)
    render

    expect(rendered).to have_content(AssetEventType.find_by(:class_name => 'ConditionUpdateEvent').description)
    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content(ConditionUpdateEvent.find_by(:asset => test_asset).get_update)
    expect(rendered).to have_content('test comment 123')
  end
end
