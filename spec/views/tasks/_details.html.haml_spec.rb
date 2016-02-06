require 'rails_helper'

describe "tasks/_details.html.haml", :type => :view do
  it 'task body' do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
    test_task = create(:task)
    assign(:task, test_task)
    render

    expect(rendered).to have_content(test_task.body)
  end
end
