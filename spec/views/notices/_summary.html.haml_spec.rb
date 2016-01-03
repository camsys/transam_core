require 'rails_helper'

describe "notices/_summary.html.haml", :type => :view do
  it 'info for org' do
    test_notice = create(:notice, :display_date => Date.today, :display_hour => 10, :end_date => Date.today + 1.day, :end_hour => 10, :organization => create(:organization))
    assign(:notice, test_notice)
    render

    expect(rendered).to have_content(Date.today.strftime('%m/%d/%Y'))
    expect(rendered).to have_content((Date.today+1.day).strftime('%m/%d/%Y'))
    expect(rendered).to have_content(test_notice.organization.to_s)
  end
  it 'no org' do
    test_notice = create(:notice, :display_datetime => Date.today, :end_datetime => Date.today + 1.day)
    assign(:notice, test_notice)
    render

    expect(rendered).to have_content('All')
  end
end
