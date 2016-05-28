require 'rails_helper'

describe "users/_actions.html.haml", :type => :view do
  it 'actions' do
    logged_in_user = create(:normal_user)
    allow(controller).to receive(:current_user).and_return(logged_in_user)
    allow(controller).to receive(:current_ability).and_return(Ability.new(logged_in_user))

    test_user = create(:normal_user, :organization => logged_in_user.organization)

    logged_in_user.organizations << logged_in_user.organization
    logged_in_user.save
    test_user.organizations << logged_in_user.organization
    test_user.save
    assign(:user, test_user)
    render

    expect(rendered).to have_link("Send #{test_user.first_name} a message")
    expect(rendered).to have_link("Assign #{test_user.first_name} a task")
    expect(rendered).to have_link("Update #{test_user.first_name}'s profile picture")
    expect(rendered).to have_link("Update #{test_user.first_name}'s settings")
    expect(rendered).to have_link("Update #{test_user.first_name}'s profile")
    expect(rendered).to have_link("Reset #{test_user.first_name}'s password")
    expect(rendered).to have_link("Deactivate this user")
  end
end
