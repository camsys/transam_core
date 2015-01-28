

### WHEN ###

# Clicks a link or button
When(/^I press the (.*?) "(.*?)"$/) do |arg1, arg2|
  if arg1 == "link"
    find(:xpath,"//a[contains(text(), '#{arg2}')]").click
  elsif arg2 == "button"
    click_button(contains(arg2))
  end
end

# TODO: build out for more functionality
# After loading a create or update form for an object
# It tests the form by changes its external id
# Arguments: create/update, object, form field (TODO)
When(/^I (.*?) the \[(.*?)\]$/) do |action, obj|
  fill_in "asset_external_id", :with => "EXTERNALID TEST 1"
  click_button "#{action.titleize} #{obj.titleize}"
end

When(/^I start the app$/) do
  visit '/users/sign_in'
end


### THEN ###

# Searches a page for a string
Then(/^I will see "(.*?)"$/) do |arg1|
  expect(page).to have_content arg1
end

# Shows the html of the page for debugging purposes
Then(/^show me the page$/) do
  print page.html
end
