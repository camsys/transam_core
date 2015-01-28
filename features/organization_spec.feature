# Update Master Record
Feature: Users can update an [organization]
     In order to make corrections or updates to an organization
     The website user
     Should obtain the ability to make and view alterations to the [organization]

  #@no-database-cleaner
  Scenario: Update for an [organization]
    Given A user with email "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data
    And an [organization] exists
    When I am at the [organization] detail page
      And I press the link "Update this organization"
      And I update a [test_org] with {:name => 'New Test Organization'}
    Then I am at the [organization] detail page
      And I will see "New Test Organization"
      And show me the page
