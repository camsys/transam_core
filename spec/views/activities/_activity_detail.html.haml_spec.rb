require 'rails_helper'

describe "activities/_activity_detail.html.haml", :type => :view do
  it 'info' do
    test_activity = create(:activity)
    render 'activities/activity_detail', :activity => test_activity

    expect(rendered).to have_content(test_activity.name)
    expect(rendered).to have_content(test_activity.description)
  end
end
