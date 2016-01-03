require 'rails_helper'

describe "tasks/_task_calendar.html.erb", :type => :view do
  it 'calendar' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    render

    expect(rendered).to have_xpath('//input[@id="state"]')
    expect(rendered).to have_xpath('//input[@id="select"]')
  end
end
