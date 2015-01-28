# Update Master Record
Feature: Users can update the master record of an [asset]
     In order to make corrections or updates to an assets master record
     The website user
     Should obtain the ability to make and view alterations to the [asset]

  #@no-database-cleaner
  Scenario: Master Record update for an [equipment]
    Given A user with email "jsoloski@catabus.com"
    And "jsoloski@catabus.com" logs in using valid user data
    And an [equipment] exists
    When I am at the [equipment] detail page
      And I press the link "Update the master record"
      And I update an [equipment] with {'external_id' => "EXTERNALID TEST 1"}
    Then I am at the [equipment] detail page
      And I will see "EXTERNALID TEST 1"
      #And show me the page
