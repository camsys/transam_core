require 'rails_helper'

describe "asset_events/_actions.html.haml", :type => :view do
  it 'actions' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_asset = create(:buslike_asset)
    test_asset.asset_events.create!(attributes_for(:condition_update_event))
    assign(:asset, test_asset)
    assign(:asset_event, test_asset.asset_events.last)
    render

    expect(rendered).to have_link('Update this record')
    expect(rendered).to have_link('Remove this record')
  end
end
