require 'rails_helper'

describe "tasks/_comments.html.haml", :type => :view do
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
