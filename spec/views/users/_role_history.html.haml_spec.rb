require 'rails_helper'

describe "users/_role_history.html.haml", :type => :view do
  it 'roles' do
    test_user = create(:normal_user)
    test_admin = create(:admin)
    allow(controller).to receive(:current_user).and_return(test_admin)

    UsersRole.where('user_id = ?', test_user.id).update_all(:granted_on_date => Date.new(2015,1,1), :granted_by_user_id => test_admin.id)
    render 'users/role_history', :user_roles => UsersRole.all

    expect(rendered).to have_content('Admin')
    expect(rendered).to have_content(test_admin.name)
    expect(rendered).to have_content('01/01/2015')
  end
end
