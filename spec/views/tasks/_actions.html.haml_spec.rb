require 'rails_helper'

describe "tasks/_actions.html.haml", :type => :view do
  it 'actions' do
    test_user = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(test_user))
    assign(:task, create(:task))
    render

    expect(rendered).to have_link('Update this task')
    expect(rendered).to have_link('Update this status...')
    expect(rendered).to have_link('Start this task')
  end
end
