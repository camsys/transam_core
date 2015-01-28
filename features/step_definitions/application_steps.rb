def is_asset(obj)
  obj.classify.constantize.ancestors.include?(Asset)
end

def is_org(obj)
  obj.classify.constantize.ancestors.include?(Organization)
end

### WHEN ###

# Clicks a link or button
When(/^I press the (.*?) "(.*?)"$/) do |arg1, arg2|
  if arg1 == "link"
    find(:xpath,"//a[contains(text(), '#{arg2}')]").click
  elsif arg2 == "button"
    click_button(contains(arg2))
  end
end

When(/^I start the app$/) do
  visit '/users/sign_in'
end

# got to the detail page
Given(/^I am at the \[(.*?)\] detail page$/) do |obj|
  if is_asset(obj)
    visit inventory_path(Asset.first)
  elsif is_org(obj)
    visit organization_path(Organization.first)
  else
    visit "/#{obj.pluralize}/#{obj.classify.constantize.first.object_key}"
  end
end


# Create/update a model object using its form
# Assumes user is already at the form
# Example: When I create a [vehicle] with {'name' => "hello"}
# Parameters:
# action can be "create" or "update"
# obj is any model with forms
# fields is a hash of field names and their values
# Issues: currently assumes hash is properly formatted
When(/^I (.*?) an? \[(.*?)\] with \{(.*?)\}$/) do |action, obj, fields|
  eval("{#{fields}}").each do |key, val|
    if is_asset(obj)
      fill_in "asset_#{key.to_s}", :with => val
    elsif is_org(obj)
      fill_in "organization_#{key.to_s}", :with => val
    else
      fill_in "#{obj.downcase}_#{key.to_s}", :with => val
    end
  end
  click_button "#{action.titleize} #{obj.humanize}"
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
