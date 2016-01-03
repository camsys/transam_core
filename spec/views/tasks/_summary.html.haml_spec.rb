require 'rails_helper'

describe "tasks/_summary.html.haml", :type => :view do
  it 'info' do
    test_user = create(:admin)
    test_asset = create(:buslike_asset)
    test_task = create(:task, :complete_by => Date.new(2010,01,01), :user => test_user, :taskable => test_asset)
    assign(:task, test_task)
    render

    expect(rendered).to have_link(test_asset.to_s)
    expect(rendered).to have_content(test_task.state.humanize)
    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content(test_user.name)
    expect(rendered).to have_content(test_task.priority_type.to_s)
  end
end
