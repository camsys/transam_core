require 'rails_helper'

describe "users/_user_details.html.haml", :type => :view do
  it 'info' do
    test_user = create(:admin, :phone => 1234567890, :phone_ext => 111, :external_id => 'test_id', :address1 => '123 Main St', :city => 'Boston', :state => 'MA', :zip => '02140')
    test_user.add_role :user
    render 'users/user_details', :user => test_user

    expect(rendered).to have_content(test_user.email)
    expect(rendered).to have_content('(123) 456-7890')
    expect(rendered).to have_content(test_user.phone_ext)
    expect(rendered).to have_content(test_user.external_id)
    expect(rendered).to have_content(test_user.address1)
    expect(rendered).to have_content('Admin')
  end
end
