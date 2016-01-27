require 'rails_helper'

describe "assets/_photos.html.haml", :type => :view do
  it 'form' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    assign(:asset, create(:buslike_asset))
    render

    expect(rendered).to have_content('There are no photos for this asset.')
    expect(rendered).to have_field('image_image')
    expect(rendered).to have_field('image_description')
  end
end
