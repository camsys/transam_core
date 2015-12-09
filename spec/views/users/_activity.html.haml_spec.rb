require 'rails_helper'

describe "users/_activity.html.haml", :type => :view do
  it 'info' do
    created = Time.new(2010,1,1,1,1,1)
    updated = Time.new(2010,2,2,2,2,2)
    signed_in = Time.new(2010,3,3,3,3,3)
    test_user = create(:normal_user, :created_at => created, :updated_at => updated, :last_sign_in_at => signed_in, :last_sign_in_ip => '127.0.0.1')
    assign(:user, test_user)
    render

    expect(rendered).to have_content('06:01 AM 01/01/2010')
    expect(rendered).to have_content('07:02 AM 02/02/2010')
    expect(rendered).to have_content('08:03 AM 03/03/2010')
    expect(rendered).to have_content('127.0.0.1')
  end
end
