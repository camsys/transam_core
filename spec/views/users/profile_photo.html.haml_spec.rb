require 'rails_helper'

describe "users/profile_photo.html.haml", :type => :view do
  it 'fields' do
    assign(:user, create(:normal_user))
    render

    expect(rendered).to have_xpath('//input[@id="image_description" and @value="Profile picture"]')
    expect(rendered).to have_field('image_image')
  end
end
