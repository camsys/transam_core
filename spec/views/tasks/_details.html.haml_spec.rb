require 'rails_helper'

describe "tasks/_details.html.haml", :type => :view do
  it 'task body' do
    test_task = create(:task)
    assign(:task, test_task)
    render

    expect(rendered).to have_content(test_task.body)
  end
end
