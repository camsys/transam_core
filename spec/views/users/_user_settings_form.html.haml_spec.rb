require 'rails_helper'

describe "users/_user_settings_form.html.haml", :type => :view do
  it 'fields' do
    assign(:user, create(:normal_user))
    render

    expect(rendered).to have_field('user_notify_via_email')
    expect(rendered).to have_field('user_num_table_rows')
    expect(rendered).to have_field('user_weather_code_id')
  end
end
