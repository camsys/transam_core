require 'rails_helper'

describe "notices/_index_table.html.haml", :type => :view do
  it 'list' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    test_notice = create(:notice, :end_datetime => Time.now+1.day)
    render 'notices/index_table', :notices => [test_notice]

    expect(rendered).to have_xpath('//a[@title="Edit this notice."]')
    expect(rendered).to have_xpath('//a[@title="Deactivate this notice. The notice will no longer show in the dashboard."]')
    expect(rendered).to have_xpath('//a[@title="Remove this notice"]')
    expect(rendered).to have_content(test_notice.object_key)
    expect(rendered).to have_content(test_notice.notice_type.to_s)
    expect(rendered).to have_content(test_notice.subject)
    expect(rendered).to have_content(test_notice.summary)
  end
end
