require 'rails_helper'

describe "dashboards/_assets_queue.html.haml", :type => :view do
  it 'no assets' do
    render 'dashboards/assets_queue', :objs => []

    expect(rendered).to have_content('No assets in queue.')
  end
end
