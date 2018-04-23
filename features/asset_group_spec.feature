Feature: Asset Groups
  In order for assets to be grouped
  The users
  Should be able to manage asset groups

Background:
  Given A user with email "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data

Scenario: Creating an asset group
  When I am at the [asset_group] index page
    And I press the link "Create new group"
    And I create an [asset_group] with {:name => "Test Group 1", :code => "TG1", :description => "Test Group Description"}
  Then I will see "TG1"

Scenario: Updating an asset group
  Given an [asset_group] exists
  When I am at the [asset_group] detail page
    And I press the link "Update this group"
    And I update an [asset_group] with {:description => "New Test Description 000"}
  Then I will see "New Test Description 000"

#Scenario: Adding an asset to an asset group
#  Given an [equipment] exists
#    And an [asset_group] exists
#  When I am at the [equipment] detail page
#    And I press the link "Add to group"
#    And I press the link "Test Group 1"
#  Then I will see "TG1"
  # under groups in the summary panel
