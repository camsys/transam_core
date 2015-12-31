require 'rails_helper'

describe "issues/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:issue, Issue.new)
    render

    expect(rendered).to have_field('issue_issue_type_id')
    expect(rendered).to have_field('issue_web_browser_type_id')
    expect(rendered).to have_field('issue_comments')
  end
end
