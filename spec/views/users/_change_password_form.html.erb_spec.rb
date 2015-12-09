require 'rails_helper'

describe "users/_change_password_form.html.erb", :type => :view do
  it 'fields' do
    assign(:user, create(:normal_user))
    render

    expect(rendered).to have_field('user_password')
    expect(rendered).to have_field('user_password_confirmation')
    expect(rendered).to have_field('user_current_password')
  end
end
