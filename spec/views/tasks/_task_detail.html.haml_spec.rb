require 'rails_helper'

describe "tasks/_task_detail.html.haml", :type => :view do
  it 'actions and info' do
    test_asset = create(:buslike_asset)
    test_task = create(:task, :complete_by => DateTime.current-1.day, :taskable => test_asset)
    test_user = create(:admin)
    assign(:organization, test_user.organization)
    render 'tasks/task_detail', :task => test_task

    expect(rendered).to have_content('New')
    expect(rendered).to have_link('Start this task')
    expect(rendered).to have_link('Remove this task')
    expect(rendered).to have_content(test_task.subject.upcase)
    expect(rendered).to have_content(test_task.body)
    expect(rendered).to have_link('Open')
    expect(rendered).to have_content('due 1 day ago')
    expect(rendered).to have_link(test_asset.to_s)
  end

  it 'assign' do
    test_task = create(:task)
    test_user = create(:admin)
    assign(:organization, test_user.organization)
    render 'tasks/task_detail', :task => test_task

    expect(rendered).to have_content('Assign')
    expect(rendered).to have_link(test_user.to_s)
  end

  it 'already assigned' do
    test_user = create(:admin)
    assign(:organization, test_user.organization)
    test_task = create(:task, :assigned_to_user => test_user)
    render 'tasks/task_detail', :task => test_task

    expect(rendered).to have_content(test_user.to_s)
    expect(rendered).to have_link('Unassign')
  end
end
