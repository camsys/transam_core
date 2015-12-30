require 'rails_helper'

describe "activities/_index_table.html.haml", :type => :view do
  it 'list' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_activity = create(:activity)
    render 'activities/index_table', :activities => [test_activity]

    expect(rendered).to have_content(test_activity.name)
    expect(rendered).to have_content(test_activity.description)
    expect(rendered).to have_content("1 #{test_activity.frequency_type.name}s at one hour")
    expect(rendered).to have_content(test_activity.job_name)
  end
end
