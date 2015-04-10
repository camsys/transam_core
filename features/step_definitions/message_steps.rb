### Given ###
Given(/^a \[message\] exists for "(.*?)"$/) do |email|
  FactoryGirl.create(:message, :to_user => User.find_by(:email => email))
end

When(/^I am at My Messages page for "(.*?)"$/) do |email|
  visit user_messages_path(User.find_by(:email => email))
end
