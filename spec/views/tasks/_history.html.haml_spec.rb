require 'rails_helper'

describe "tasks/_history.html.haml", :type => :view do
  it 'no history' do
    test_task = create(:task)
    assign(:task, test_task)
    render

    expect(rendered).to have_content('There are no workflow events associated with this task.')
  end
  it 'history' do
    test_user = create(:admin)
    test_task = create(:task)
    WorkflowEvent.create!(:accountable_id => test_task.id, :accountable_type => 'Task', :event_type => 'start', :created_at => Time.new(2010,1,1,10,10), :creator => test_user)
    assign(:task, test_task)
    render

    expect(rendered).to have_content('01/01/2010')
    expect(rendered).to have_content(':10')
    expect(rendered).to have_content('Start')
    expect(rendered).to have_content(test_user.name)
  end
end
