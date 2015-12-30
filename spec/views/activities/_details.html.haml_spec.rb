require 'rails_helper'

describe "activities/_details.html.haml", :type => :view do
  it 'info' do
    test_activity = create(:activity)
    assign(:activity, test_activity)
    render

    expect(rendered).to have_content(test_activity.description)
  end
end
