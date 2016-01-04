require 'rails_helper'

describe "assets/_tasks.html.haml", :type => :view do
  it 'form' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:asset, create(:buslike_asset))
    render

    expect(rendered).to have_content('There are no tasks for this asset.')
    expect(rendered).to have_field('task_subject')
    expect(rendered).to have_field('task_assigned_to_user_id')
    expect(rendered).to have_field('task_complete_by')
    expect(rendered).to have_field('task_priority_type_id')
    expect(rendered).to have_field('task_send_reminder')
    expect(rendered).to have_field('task_body')
  end
end
