### WHEN ###
When(/^I am at the "New Message" page$/) do
  visit new_user_message_path(User.first)
end
