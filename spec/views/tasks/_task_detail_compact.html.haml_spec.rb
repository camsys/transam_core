require 'rails_helper'

describe "tasks/_task_detail_compact.html.haml", :type => :view do
  it 'info' do
    allow(controller).to receive(:current_user).and_return(create(:admin))
    test_task = create(:task, :complete_by => Date.today)
    render 'tasks/task_detail_compact', :task => test_task

    expect(rendered).to have_content('1 day ago')
    expect(rendered).to have_content(test_task.body)
  end
end
