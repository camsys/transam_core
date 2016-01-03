require 'rails_helper'

describe "tasks/index.html.haml", :type => :view do
  it 'links and no tasks' do
    Task.destroy_all
    allow(controller).to receive(:current_user).and_return(create(:admin))
    assign(:open_tasks, Task.all)
    assign(:closed_tasks, Task.all)
    assign(:organization, create(:organization))
    render

    expect(rendered).to have_link('Refresh')
    expect(rendered).to have_link('New Task')
    expect(rendered).to have_link('My Open Tasks')
    expect(rendered).to have_link('My Completed Tasks')
    expect(rendered).to have_link('Tasks Assigned to Others')
    expect(rendered).to have_link('Unassigned Tasks')
    expect(rendered).to have_link('Cancelled Tasks')
    expect(rendered).to have_content('You have no tasks waiting')
    expect(rendered).to have_content('You have no completed tasks')
    expect(rendered).to have_content('No tasks found')
    expect(rendered).to have_content('No tasks unassigned')
    expect(rendered).to have_content('No tasks cancelled')
  end
end
