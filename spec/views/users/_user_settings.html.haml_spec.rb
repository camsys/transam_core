require 'rails_helper'

describe "users/_user_settings.html.haml", :type => :view do
  it 'settings' do
    test_user = create(:normal_user, :weather_code => WeatherCode.create!(:state => 'NY', :code => 'USNY0996', :city => 'New York City', :active => true))
    assign(:user, test_user)
    render

    expect(rendered).to have_content('No')
    expect(rendered).to have_content(test_user.num_table_rows)
    expect(rendered).to have_content('New York City')
  end
end
