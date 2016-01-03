require 'rails_helper'

describe "tasks/_form.html.haml", :type => :view do
  it 'fields' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:task, Task.new)
    render

    expect(rendered).to have_field('task_subject')
    expect(rendered).to have_field('task_complete_by')
    expect(rendered).to have_field('task_priority_type_id')
    expect(rendered).to have_field('task_send_reminder')
    expect(rendered).to have_field('task_body')
  end
end
