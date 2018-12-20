require 'rails_helper'

describe "users/_activity.html.haml", :type => :view do
  it 'info' do
    created = Time.new(2010,1,1,1,1,1)
    updated = Time.new(2010,2,2,2,2,2)
    signed_in = Time.new(2010,3,3,3,3,3)
    test_user = create(:normal_user, :created_at => created, :updated_at => updated, :last_sign_in_at => signed_in, :last_sign_in_ip => '127.0.0.1')
    assign(:user, test_user)
    render

    expect(rendered).to have_content(test_user.created_at.strftime("%m/%d/%Y %I:%M %p"))
    expect(rendered).to have_content(test_user.updated_at.strftime("%m/%d/%Y %I:%M %p"))
    expect(rendered).to have_content(test_user.last_sign_in_at.strftime("%m/%d/%Y %I:%M %p"))
    expect(rendered).to have_content('127.0.0.1')
  end
end
