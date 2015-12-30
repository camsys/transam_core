require 'rails_helper'

describe "activities/_summary.html.haml", :type => :view do
  it 'info' do
    test_activity = create(:activity)
    render 'activities/summary', :activity => test_activity

    expect(rendered).to have_content(test_activity.name)
    expect(rendered).to have_content("1 #{test_activity.frequency_type.name}s at one hour")
    expect(rendered).to have_content(test_activity.job_name)
  end
end
