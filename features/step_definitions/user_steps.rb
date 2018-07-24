#### MOCK CLASSES ####

class TestOrg < Organization
  has_many :assets,   :foreign_key => 'organization_id'

  def get_policy
    return Policy.where("`organization_id` = ?",self.id).order('created_at').last
  end
end


### UTILITY METHODS ###
def create_user(email, org_short_name)
  o = Organization.find_by(:short_name => org_short_name)
  user = FactoryBot.build(:normal_user, :email => email, :organization => o)

  user.organizations << o
  user.save!

  user.add_role :user
  user.add_role :admin
end

def sign_out
  current_driver = Capybara.current_driver
  begin
    Capybara.current_driver = :rack_test
    page.driver.submit :delete, "/users/sign_out", {}
  ensure
    Capybara.current_driver = current_driver
  end
end

def sign_in(email, password)
  visit '/users/sign_in'
  fill_in "user_email", :with => email
  fill_in "user_password", :with => password
  click_button "Sign in"
end

### GIVEN ###
Given(/^A user with email "(.*?)"$/) do |user_email|
  org1 = create_organization
  create_user(user_email, org1.short_name)
end

Given(/^"(.*?)" is logged in$/) do |arg1|
  sign_in(arg1, "Welcome1")
end

Given(/^"(.*?)" is not logged in$/) do |arg1|
  sign_out
end

### WHEN ###
When(/^"(.*?)" logs in using valid user data$/) do |email|
  sign_in(email, "Welcome1")
end

When(/^"(.*?)" logs in using invalid user data$/) do |email|
  sign_in(email, "Welcome2")
end

When(/^I fill out the forgotten password form with "(.*?)"$/) do |email|
  fill_in "user_email", :with => email
  click_button "Send me reset password instructions"
end

When(/^The user logs out$/) do
  sign_out
end


# When /^I sign out$/ do
#   visit '/users/sign_out'
# end

# When /^I sign up with valid user data$/ do
#   create_visitor
#   sign_up
# end

# When /^I sign up with an invalid email$/ do
#   create_visitor
#   @visitor = @visitor.merge(:email => "notanemail")
#   sign_up
# end

# When /^I sign up without a password confirmation$/ do
#   create_visitor
#   @visitor = @visitor.merge(:password_confirmation => "")
#   sign_up
# end

# When /^I sign up without a password$/ do
#   create_visitor
#   @visitor = @visitor.merge(:password => "")
#   sign_up
# end

# When /^I sign up with a mismatched password confirmation$/ do
#   create_visitor
#   @visitor = @visitor.merge(:password_confirmation => "changeme123")
#   sign_up
# end

# When /^I return to the site$/ do
#   visit '/'
# end

# When /^I sign in with a wrong email$/ do
#   @visitor = @visitor.merge(:email => "wrong@example.com")
#   sign_in
# end

# When /^I sign in with a wrong password$/ do
#   @visitor = @visitor.merge(:password => "wrongpass")
#   sign_in
# end

# When /^I edit my account details$/ do
#   click_link "Edit account"
#   fill_in "user_name", :with => "newname"
#   fill_in "user_current_password", :with => @visitor[:password]
#   click_button "Update"
# end

# When /^I look at the list of users$/ do
#   visit '/'
# end

### THEN ###

Then(/^The user will be signed out$/) do
  expect(page).to have_field "user_email"
  expect(page).to have_field "user_password"
  expect(page).to have_button "Sign in"
end

# Then(/^I should see "(.*?)"$/) do |arg1|
#   expect(page).to have_content arg1
# end

# Then /^I should be signed out$/ do
#   page.should have_content "Sign up"
#   page.should have_content "Login"
#   page.should_not have_content "Logout"
# end

# Then /^I see an unconfirmed account message$/ do
#   page.should have_content "You have to confirm your account before continuing."
# end

# Then /^I see a successful sign in message$/ do
#   page.should have_content "Signed in successfully."
# end

# Then /^I should see a successful sign up message$/ do
#   page.should have_content "Welcome! You have signed up successfully."
# end

# Then /^I should see an invalid email message$/ do
#   page.should have_content "Email is invalid"
# end

# Then /^I should see a missing password message$/ do
#   page.should have_content "Password can't be blank"
# end

# Then /^I should see a missing password confirmation message$/ do
#   page.should have_content "Password doesn't match confirmation"
# end

# Then /^I should see a mismatched password message$/ do
#   page.should have_content "Password doesn't match confirmation"
# end

# Then /^I should see a signed out message$/ do
#   page.should have_content "Signed out successfully."
# end

# Then /^I see an invalid login message$/ do
#   page.should have_content "Invalid email or password."
# end

# Then /^I should see an account edited message$/ do
#   page.should have_content "You updated your account successfully."
# end

# Then /^I should see my name$/ do
#   create_user
#   page.should have_content user[:name]
# end
