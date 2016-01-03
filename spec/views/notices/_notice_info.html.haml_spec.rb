require 'rails_helper'

describe "notices/_notice_info.html.haml", :type => :view do
  it 'info' do
    test_notice = create(:notice)
    assign(:notice, test_notice)
    render

    expect(rendered).to have_content('Test Subject')
    expect(rendered).to have_content(test_notice.summary)
    expect(rendered).to have_content(test_notice.details)
  end
end
