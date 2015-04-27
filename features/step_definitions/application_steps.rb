def is_asset(obj)
  obj.classify.constantize.ancestors.include?(Asset)
end

def is_org(obj)
  obj.classify.constantize.ancestors.include?(Organization)
end

def is_asset_event(obj)
  obj.classify.constantize.ancestors.include?(AssetEvent)
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

# go to the index page
When(/^I am at the \[(.*?)\] index page$/) do |obj|
  if is_asset(obj)
    visit inventory_path
  elsif is_org(obj)
    visit organizations_path
  else
    visit "/#{obj.pluralize}"
  end
end

# go to the detail page
When(/^I am at the \[(.*?)\] detail page$/) do |obj|
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
      if has_field?("asset_#{key.to_s}", :type => 'select')
        select(val, from: "asset_#{key.to_s}")
      else
        fill_in "asset_#{key.to_s}", :with => val
      end
    elsif is_asset_event(obj)
      if has_field?("asset_event_#{key.to_s}", :type => 'select')
        select(val, from: "asset_event_#{key.to_s}")
      else
        fill_in "asset_event_#{key.to_s}", :with => val
      end
    elsif is_org(obj)
      if has_field?("organization_#{key.to_s}", :type => 'select')
        select(val, from: "organization_#{key.to_s}")
      else
        fill_in "organization_#{key.to_s}", :with => val
      end
    else
      if has_field?("#{obj.downcase}_#{key.to_s}", :type => 'select')
        select(val, from: "#{obj.downcase}_#{key.to_s}")
      else
        fill_in "#{obj.downcase}_#{key.to_s}", :with => val
      end
    end
  end
  #click_button "#{action.titleize} #{obj.humanize}"
  find(:xpath, "//input[contains(@name, 'commit')]").click()
end


### THEN ###

# Searches a page for a string
Then(/^I will see "(.*?)"$/) do |arg1|
  expect(page).to have_content arg1
end

Then(/^I will not see "(.*?)"$/) do |arg1|
  expect(page).not_to have_content arg1
end

# Shows the html of the page for debugging purposes
Then(/^show me the page$/) do
  print page.html
end
