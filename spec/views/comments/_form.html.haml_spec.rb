require 'rails_helper'

describe "comments/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:commentable, create(:buslike_asset))
    render

    expect(rendered).to have_field('comment_comment')
  end
end
