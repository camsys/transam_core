require 'rails_helper'

describe "tasks/_comments.html.haml", :type => :view do
  before(:each) do
    allow(controller).to receive(:current_ability).and_return(Ability.new(create(:admin)))
  end

  it 'no comments' do
    assign(:task, create(:task))
    render

    expect(rendered).to have_content('There are no comments for this task.')
  end
  it 'add comment' do
    assign(:task, create(:task))
    render

    expect(rendered).to have_field('comment_comment')
  end
end
