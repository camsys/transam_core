require 'rails_helper'

describe "users/_user_card.html.haml", :type => :view do
  it 'info' do
    test_user = create(:normal_user, :title => 'software engineer')
    render 'users/user_card', :user => test_user

    expect(rendered).to have_content(test_user.name)
    expect(rendered).to have_content(test_user.title)
  end
end
