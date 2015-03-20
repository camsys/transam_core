### Given ###
Given(/^a \[message\] exists for "(.*?)"$/) do |email|
  FactoryGirl.create(:message, :to_user => User.find_by(:email => email))
end

### WHEN ###
When(/^I am at the "New Message" page$/) do
  visit new_user_message_path(User.first)
end
