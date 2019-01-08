require 'rails_helper'

describe "images/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:imagable, create(:buslike_asset))
    assign(:image, Image.new)
    render

    expect(rendered).to have_field('image_image')
    expect(rendered).to have_field('image_description')
  end
end
